#!/bin/sh
# Pixaroma workflow + model installer for ComfyUI.
#
# Installs the 40 episode workflow packs from ./archives and downloads the model
# files those workflows load from Hugging Face. Existing files are never
# re-downloaded unless --force-models is given.
#
# Usage:
#   ./setup.sh workflows [options]
#   ./setup.sh models --episode 6 [options]
#   ./setup.sh all --episode 6 [options]
#   ./setup.sh list [--episode 6]
#
# Run ./setup.sh --help for the full option list.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
MANIFEST="$SCRIPT_DIR/models.psv"

TARGET=""
EP_SELECTOR=""
ALL=0
COMFYUI_ARG=""
MODELS_ROOT_ARG=""
CONF="$SCRIPT_DIR/pixaroma.conf"
DRY=0
YES=0
VERIFY=0
FORCE_MODELS=0
FORCE_WORKFLOWS=0
ALL_ZIP=0

die() {
    printf 'error: %s\n' "$*" >&2
    exit 2
}

usage() {
    cat <<'EOF'
Pixaroma workflow + model installer for ComfyUI

Targets:
  workflows        Extract workflow packs (default: all 40)
  models           Download models used by the selected episodes
  all              Workflows + models
  list             Print the model catalog (no writes)

Selection:
  --episode N      Episode number, e.g. 6, 06, Ep06. Repeatable or comma-separated.
  --all            All episodes. Required for `models` when --episode is omitted.

Paths:
  --comfyui PATH   ComfyUI root (the folder containing models/ and user/).
                   Auto-detected from the script folder and current directory if omitted.
                   The COMFYUI_DIR environment variable is also honored.
  --models-root PATH
                   Store models in a shared folder that uses ComfyUI folder names
                   (checkpoints/, loras/, vae/, ...). Defaults to <ComfyUI>/models,
                   or the MODELS_ROOT value saved in pixaroma.conf.

Safety:
  --dry-run        Show what would be downloaded/extracted; write nothing.
  --yes            Skip the confirmation prompt for a full `models` install.
  --verify         Check installed model sizes; download nothing. Exit 1 on problems.
  --force-models   Re-download models even if the target file exists.
  --force-workflows  Overwrite workflow files instead of keeping existing ones.
  --all-zip        Extract all-workflows.zip instead of the 40 episode zips.

Examples:
  ./setup.sh workflows --comfyui ~/ComfyUI
  ./setup.sh models --episode 6 --comfyui ~/ComfyUI
  ./setup.sh all --episode 25 --comfyui ~/ComfyUI
  ./setup.sh models --all --yes --comfyui ~/ComfyUI
  ./setup.sh list --episode 39

Model files go to <ComfyUI>/models/<folder>/<file> exactly as the workflows expect.
Workflows go to <ComfyUI>/user/default/workflows/Pixaroma/.
Requires the `hf` CLI: pip install -U "huggingface_hub[cli]".
EOF
}

# ---------------------------------------------------------------- arg parsing
add_episodes() {
    old_ifs=$IFS
    IFS=', '
    for raw in $1; do
        [ -n "$raw" ] || continue
        n=$(printf '%s' "$raw" | sed -n 's/^[Ee][Pp]*0*\([0-9][0-9]*\)$/\1/p')
        [ -n "$n" ] || n=$(printf '%s' "$raw" | sed -n 's/^0*\([0-9][0-9]*\)$/\1/p')
        [ -n "$n" ] || { IFS=$old_ifs; die "invalid episode: $raw"; }
        n=$(printf '%s' "$n" | sed 's/^0*//')
        [ -n "$n" ] || n=0
        if [ "$n" -lt 10 ]; then n="0$n"; fi
        case ",$EP_SELECTOR," in
            *",$n,"*) ;;
            *) EP_SELECTOR="${EP_SELECTOR:+$EP_SELECTOR,}$n" ;;
        esac
    done
    IFS=$old_ifs
}

while [ $# -gt 0 ]; do
    case "$1" in
        workflows|models|all|list)
            TARGET=$1
            shift
            ;;
        --episode)
            [ $# -ge 2 ] || die "--episode needs a value"
            add_episodes "$2"
            shift 2
            ;;
        --episode=*)
            add_episodes "${1#*=}"
            shift
            ;;
        --all)
            ALL=1
            shift
            ;;
        --comfyui)
            [ $# -ge 2 ] || die "--comfyui needs a path"
            COMFYUI_ARG=$2
            shift 2
            ;;
        --comfyui=*)
            COMFYUI_ARG=${1#*=}
            shift
            ;;
        --models-root)
            [ $# -ge 2 ] || die "--models-root needs a path"
            MODELS_ROOT_ARG=$2
            shift 2
            ;;
        --models-root=*)
            MODELS_ROOT_ARG=${1#*=}
            shift
            ;;
        --dry-run)
            DRY=1
            shift
            ;;
        --yes|-y)
            YES=1
            shift
            ;;
        --verify)
            VERIFY=1
            shift
            ;;
        --force-models)
            FORCE_MODELS=1
            shift
            ;;
        --force-workflows)
            FORCE_WORKFLOWS=1
            shift
            ;;
        --all-zip)
            ALL_ZIP=1
            shift
            ;;
        -h|--help)
            usage
            exit 0
            ;;
        *)
            die "unknown argument: $1 (try --help)"
            ;;
    esac
done

[ -n "$TARGET" ] || { usage; exit 2; }
[ -f "$MANIFEST" ] || die "models.psv not found next to this script"

if [ -n "$EP_SELECTOR" ] && [ "$ALL" = 1 ]; then
    die "use --episode or --all, not both"
fi
if [ -n "$EP_SELECTOR" ] && [ "$ALL_ZIP" = 1 ]; then
    die "--all-zip extracts the aggregate pack; it cannot be filtered by episode"
fi
if [ "$TARGET" = "models" ] && [ -z "$EP_SELECTOR" ] && [ "$ALL" != 1 ]; then
    die "models needs --episode N (repeatable) or --all"
fi
if [ "$TARGET" = "all" ] && [ -z "$EP_SELECTOR" ] && [ "$ALL" != 1 ]; then
    die "all needs --episode N (repeatable) or --all"
fi
if [ "$VERIFY" = 1 ] && [ "$FORCE_MODELS" = 1 ]; then
    die "--verify cannot be combined with --force-models"
fi

# ------------------------------------------------------------ saved defaults
if [ -f "$CONF" ]; then
    while IFS= read -r line || [ -n "$line" ]; do
        case "$line" in
            ''|\#*) continue ;;
            COMFYUI=*) [ -n "$COMFYUI_ARG" ] || COMFYUI_ARG=${line#COMFYUI=} ;;
            MODELS_ROOT=*) [ -n "$MODELS_ROOT_ARG" ] || MODELS_ROOT_ARG=${line#MODELS_ROOT=} ;;
        esac
    done < "$CONF"
fi

human() {
    awk -v b="${1:-0}" 'BEGIN {
        if (b >= 1e12) printf "%.2f TB", b/1e12;
        else if (b >= 1e9) printf "%.2f GB", b/1e9;
        else if (b >= 1e6) printf "%.2f MB", b/1e6;
        else if (b >= 1e3) printf "%.1f KB", b/1e3;
        else printf "%.0f B", b;
    }'
}

row_selected() {
    eps=$1
    [ "$ALL" = 1 ] && return 0
    [ -n "$EP_SELECTOR" ] || return 1
    old_ifs=$IFS
    IFS=','
    for e in $eps; do
        case ",$EP_SELECTOR," in
            *",$e,"*) IFS=$old_ifs; return 0 ;;
        esac
    done
    IFS=$old_ifs
    return 1
}

ep_selected() {
    [ -z "$EP_SELECTOR" ] && return 0
    case ",$EP_SELECTOR," in
        *",$1,"*) return 0 ;;
        *) return 1 ;;
    esac
}

# --------------------------------------------------------------- ComfyUI root
COMFY=""
try_comfy() {
    [ -z "$COMFY" ] || return 0
    [ -n "$1" ] || return 0
    c=$1
    if [ "$(basename -- "$c")" = "models" ]; then
        c=$(dirname -- "$c")
    fi
    if [ -d "$c/models" ]; then
        COMFY=$(CDPATH= cd -- "$c" && pwd)
    fi
}

if [ -n "$COMFYUI_ARG" ]; then
    try_comfy "$COMFYUI_ARG"
    [ -n "$COMFY" ] || die "$COMFYUI_ARG does not look like a ComfyUI folder (no models/ inside)"
else
    try_comfy "${COMFYUI_DIR:-}"
    try_comfy "$SCRIPT_DIR/ComfyUI"
    try_comfy "$SCRIPT_DIR/../ComfyUI"
    try_comfy "$SCRIPT_DIR/ComfyUI_windows_portable/ComfyUI"
    try_comfy "$SCRIPT_DIR/../ComfyUI_windows_portable/ComfyUI"
    try_comfy "$SCRIPT_DIR/ComfyUI-Easy-Install/ComfyUI"
    try_comfy "$SCRIPT_DIR/../ComfyUI-Easy-Install/ComfyUI"
    try_comfy "$PWD/ComfyUI"
    try_comfy "$PWD"
    try_comfy "$PWD/.."
    try_comfy "$HOME/ComfyUI"
    try_comfy "$HOME/ComfyUI_windows_portable/ComfyUI"
fi

if { [ "$TARGET" = "workflows" ] || [ "$TARGET" = "all" ]; } && [ -z "$COMFY" ]; then
    die "ComfyUI not found. Pass --comfyui /path/to/ComfyUI"
fi

if [ -n "$MODELS_ROOT_ARG" ]; then
    MODELS_DIR=$MODELS_ROOT_ARG
elif [ -n "$COMFY" ]; then
    MODELS_DIR="$COMFY/models"
else
    MODELS_DIR=""
fi

if [ "$TARGET" = "models" ] && [ -z "$MODELS_DIR" ]; then
    die "models needs --models-root /path/to/models (or a ComfyUI install)"
fi

WF_ROOT="${COMFY:+$COMFY/user/default/workflows/Pixaroma}"

# ---------------------------------------------------------------- archives dir
ARCHIVES="$SCRIPT_DIR/archives"
[ -d "$ARCHIVES" ] || ARCHIVES="$SCRIPT_DIR"

# --------------------------------------------------------------------- listing
if [ "$TARGET" = "list" ] && [ -z "$EP_SELECTOR" ]; then
    ALL=1
fi

if [ "$TARGET" = "list" ]; then
    printf '%10s  %-66s %-22s %s\n' "SIZE" "FOLDER/FILE" "EPISODES" "SOURCE"
    total=0
    count=0
    manual_count=0
    while IFS='|' read -r folder filename bytes repo repo_path eps url gated note; do
        [ "$folder" = "folder" ] && continue
        row_selected "$eps" || continue
        count=$((count + 1))
        if [ "$repo" = "-" ]; then
            size="manual"
            src="manual"
            manual_count=$((manual_count + 1))
        else
            size=$(human "$bytes")
            total=$((total + bytes))
            src=$repo
            [ "$gated" = "yes" ] && src="$src (gated)"
        fi
        printf '%10s  %-66s %-22s %s\n' "$size" "$folder/$filename" "$eps" "$src"
    done < "$MANIFEST"
    printf '\n%d files selected, %s downloadable' "$count" "$(human "$total")"
    [ "$manual_count" -gt 0 ] && printf ', %d manual' "$manual_count"
    printf '.\n'
    exit 0
fi

# ------------------------------------------------------------- workflows first
install_workflows() {
    command -v unzip >/dev/null 2>&1 || die "unzip is required for workflow extraction"
    printf '\n== Workflows ==\n'
    if [ "$DRY" = 1 ]; then
        printf '[dry-run] would extract into %s\n' "$WF_ROOT"
    else
        mkdir -p "$WF_ROOT"
    fi
    before=$(find "$WF_ROOT" -name '*.json' 2>/dev/null | wc -l | tr -d ' ')
    zips=0
    if [ "$ALL_ZIP" = 1 ]; then
        zip="$ARCHIVES/all-workflows.zip"
        [ -f "$zip" ] || die "all-workflows.zip not found in $ARCHIVES"
        if [ "$DRY" = 1 ]; then
            printf '[dry-run] extract %s\n' "$(basename -- "$zip")"
        else
            if [ "$FORCE_WORKFLOWS" = 1 ]; then
                unzip -o -q "$zip" -d "$WF_ROOT"
            else
                unzip -n -q "$zip" -d "$WF_ROOT"
            fi
            printf '[wf] %s -> %s\n' "$(basename -- "$zip")" "$WF_ROOT"
        fi
        zips=1
    else
        for zip in "$ARCHIVES"/*.zip; do
            [ -f "$zip" ] || continue
            base=$(basename -- "$zip")
            [ "$base" = "all-workflows.zip" ] && continue
            n=$(printf '%s' "$base" | sed -n 's/^[Ee][Pp]0*\([0-9][0-9]*\)[^0-9].*/\1/p')
            [ -n "$n" ] || continue
            n=$(printf '%s' "$n" | sed 's/^0*//')
            [ -n "$n" ] || n=0
            if [ "$n" -lt 10 ]; then n="0$n"; fi
            ep_selected "$n" || continue
            if [ "$DRY" = 1 ]; then
                printf '[dry-run] extract %s\n' "$base"
            else
                if [ "$FORCE_WORKFLOWS" = 1 ]; then
                    unzip -o -q "$zip" -d "$WF_ROOT"
                else
                    unzip -n -q "$zip" -d "$WF_ROOT"
                fi
                printf '[wf] %s\n' "$base"
            fi
            zips=$((zips + 1))
        done
    fi
    [ "$zips" -gt 0 ] || die "no matching workflow zips found in $ARCHIVES"
    if [ "$DRY" = 1 ]; then
        printf '[dry-run] %d zip(s) selected\n' "$zips"
    else
        after=$(find "$WF_ROOT" -name '*.json' 2>/dev/null | wc -l | tr -d ' ')
        printf '[wf] %d zip(s) processed; %s JSON files in %s\n' "$zips" "$after" "$WF_ROOT"
        [ "$FORCE_WORKFLOWS" = 1 ] || printf '[wf] existing workflow files were kept (use --force-workflows to overwrite)\n'
    fi
}

if [ "$TARGET" = "workflows" ] || [ "$TARGET" = "all" ]; then
    install_workflows
fi

if [ "$TARGET" = "workflows" ]; then
    exit 0
fi

# --------------------------------------------------------------------- models
if [ "$VERIFY" != 1 ]; then
    command -v hf >/dev/null 2>&1 || die "the 'hf' CLI is not installed (pip install -U \"huggingface_hub[cli]\")"
fi

selected_files=0
selected_bytes=0
manual_count=0
gated_count=0
present_files=0
present_bytes=0
to_fetch_files=0
to_fetch_bytes=0
mismatch_files=0
missing_files=0

while IFS='|' read -r folder filename bytes repo repo_path eps url gated note; do
    [ "$folder" = "folder" ] && continue
    row_selected "$eps" || continue
    selected_files=$((selected_files + 1))
    target="$MODELS_DIR/$folder/$filename"
    if [ "$repo" = "-" ]; then
        manual_count=$((manual_count + 1))
        if [ -f "$target" ]; then
            present_files=$((present_files + 1))
        else
            missing_files=$((missing_files + 1))
            [ "$VERIFY" = 1 ] && printf '[missing] %s/%s (manual)\n' "$folder" "$filename"
        fi
        continue
    fi
    selected_bytes=$((selected_bytes + bytes))
    [ "$gated" = "yes" ] && gated_count=$((gated_count + 1))
    if [ -f "$target" ] && [ "$FORCE_MODELS" != 1 ]; then
        actual=$(stat -c %s "$target" 2>/dev/null || stat -f %z "$target")
        present_files=$((present_files + 1))
        present_bytes=$((present_bytes + bytes))
        if [ "$actual" -ne "$bytes" ]; then
            mismatch_files=$((mismatch_files + 1))
            printf '[warn] size mismatch (leaving file untouched): %s/%s (%s bytes, expected %s)\n' \
                "$folder" "$filename" "$actual" "$bytes"
        fi
    else
        to_fetch_files=$((to_fetch_files + 1))
        to_fetch_bytes=$((to_fetch_bytes + bytes))
        if [ "$VERIFY" = 1 ] && [ "$FORCE_MODELS" != 1 ]; then
            printf '[missing] %s/%s\n' "$folder" "$filename"
        fi
    fi
done < "$MANIFEST"

if [ "$selected_files" -eq 0 ]; then
    printf 'No model files are referenced by the selected episode(s).\n'
    exit 0
fi

printf '\n== Models ==\n'
printf 'Folder:      %s\n' "$MODELS_DIR"
printf 'Selected:    %d files, %s downloadable' "$selected_files" "$(human "$selected_bytes")"
[ "$manual_count" -gt 0 ] && printf ', %d manual' "$manual_count"
printf '\n'
printf 'Present:     %d files (%s)\n' "$present_files" "$(human "$present_bytes")"
printf 'To download: %d files (%s)\n' "$to_fetch_files" "$(human "$to_fetch_bytes")"
[ "$mismatch_files" -gt 0 ] && printf 'Size issues: %d existing file(s) (see warnings above)\n' "$mismatch_files"
[ "$gated_count" -gt 0 ] && printf 'Gated:       %d file(s) from black-forest-labs/flux-3-image-klein-comfy\n' "$gated_count"

if [ "$VERIFY" = 1 ]; then
    printf '\nVerification only; nothing downloaded.\n'
    [ "$to_fetch_files" -eq 0 ] && [ "$missing_files" -eq 0 ] && [ "$mismatch_files" -eq 0 ] && exit 0
    exit 1
fi

if [ "$ALL" = 1 ] && [ "$DRY" != 1 ] && [ "$YES" != 1 ] && [ "$to_fetch_files" -gt 0 ]; then
    printf '\nThis will download %s. Continue? [y/N] ' "$(human "$to_fetch_bytes")"
    if [ ! -t 0 ]; then
        printf '\nNot a terminal. Re-run with --yes to confirm.\n'
        exit 2
    fi
    read -r answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *) printf 'Aborted.\n'; exit 1 ;;
    esac
fi

HF_AUTH_OK=0
if [ "$gated_count" -gt 0 ] && hf auth whoami >/dev/null 2>&1; then
    HF_AUTH_OK=1
fi

STAGE_ROOT="$MODELS_DIR/.pixaroma-staging"
downloaded_files=0
downloaded_bytes=0
failed_files=0
failed_bytes=0
gate_skipped=0
index=0

while IFS='|' read -r folder filename bytes repo repo_path eps url gated note; do
    [ "$folder" = "folder" ] && continue
    row_selected "$eps" || continue
    index=$((index + 1))
    target="$MODELS_DIR/$folder/$filename"
    if [ "$repo" = "-" ]; then
        if [ -f "$target" ]; then
            printf '[%3d/%3d] [manual-present] %s/%s\n' "$index" "$selected_files" "$folder" "$filename"
        else
            printf '[%3d/%3d] [manual] %s/%s — supply this file yourself\n' "$index" "$selected_files" "$folder" "$filename"
        fi
        continue
    fi
    if [ -f "$target" ] && [ "$FORCE_MODELS" != 1 ]; then
        printf '[%3d/%3d] [skip] %s/%s (%s)\n' "$index" "$selected_files" "$folder" "$filename" "$(human "$bytes")"
        continue
    fi
    if [ "$DRY" = 1 ]; then
        printf '[%3d/%3d] [dry-run] %s  %s/%s\n' "$index" "$selected_files" "$(human "$bytes")" "$folder" "$filename"
        printf '              %s\n' "$url"
        [ "$gated" = "yes" ] && printf '              gated: accept the license and run hf auth login\n'
        if hf download "$repo" "$repo_path" --dry-run --quiet >/dev/null 2>&1; then
            printf '              remote: ok\n'
        else
            printf '              remote: check failed (network or access)\n'
        fi
        continue
    fi
    if [ "$gated" = "yes" ] && [ "$HF_AUTH_OK" != 1 ]; then
        printf '[%3d/%3d] [gate] %s/%s — accept the license and run: hf auth login\n' \
            "$index" "$selected_files" "$folder" "$filename"
        gate_skipped=$((gate_skipped + 1))
        continue
    fi

    printf '[%3d/%3d] [dl] %s  %s/%s\n' "$index" "$selected_files" "$(human "$bytes")" "$folder" "$filename"
    printf '              %s\n' "$url"

    hash=$(printf '%s' "$repo/$repo_path" | cksum | awk '{print $1 "-" $2}')
    stage="$STAGE_ROOT/$hash"
    mkdir -p "$stage"
    if ! hf download "$repo" "$repo_path" --local-dir "$stage"; then
        printf '[fail] download failed: %s/%s\n' "$folder" "$filename"
        if [ "$gated" = "yes" ]; then
            printf '       Accept the license at https://huggingface.co/%s and run: hf auth login\n' "$repo"
        fi
        failed_files=$((failed_files + 1))
        failed_bytes=$((failed_bytes + bytes))
        printf '       partial data kept in %s (re-run to resume)\n' "$stage"
        continue
    fi
    src="$stage/$repo_path"
    if [ ! -f "$src" ]; then
        printf '[fail] hf reported success but %s is missing\n' "$src"
        failed_files=$((failed_files + 1))
        failed_bytes=$((failed_bytes + bytes))
        continue
    fi
    actual=$(stat -c %s "$src" 2>/dev/null || stat -f %z "$src")
    if [ "$actual" -ne "$bytes" ]; then
        printf '[warn] downloaded size %s differs from expected %s; installing anyway\n' "$actual" "$bytes"
    fi
    mkdir -p "$MODELS_DIR/$folder"
    if ! mv -f "$src" "$target"; then
        printf '[fail] could not move %s into place\n' "$src"
        failed_files=$((failed_files + 1))
        failed_bytes=$((failed_bytes + bytes))
        continue
    fi
    rm -rf "$stage"
    downloaded_files=$((downloaded_files + 1))
    downloaded_bytes=$((downloaded_bytes + bytes))
done < "$MANIFEST"

# Remove the staging root only when every download moved out cleanly.
rmdir "$STAGE_ROOT" 2>/dev/null || true

printf '\n== Summary ==\n'
printf 'Downloaded: %d files (%s)\n' "$downloaded_files" "$(human "$downloaded_bytes")"
printf 'Already present: %d files (%s)\n' "$present_files" "$(human "$present_bytes")"
printf 'Failed: %d files (%s)\n' "$failed_files" "$(human "$failed_bytes")"
[ "$gate_skipped" -gt 0 ] && printf 'Gated, not downloaded: %d file(s)\n' "$gate_skipped"
if [ "$manual_count" -gt 0 ]; then
    printf '\nManual file(s):\n'
    while IFS='|' read -r folder filename bytes repo repo_path eps url gated note; do
        [ "$folder" = "folder" ] && continue
        [ "$repo" = "-" ] || continue
        row_selected "$eps" || continue
        printf '  %s/%s\n    %s\n' "$folder" "$filename" "$note"
    done < "$MANIFEST"
fi

if [ "$failed_files" -gt 0 ] || [ "$gate_skipped" -gt 0 ]; then
    exit 1
fi
exit 0
