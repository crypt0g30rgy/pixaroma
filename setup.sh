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
#   ./setup.sh shorts --type short --install [options]
#   ./setup.sh --short --install [options]
#
# Run ./setup.sh --help for the full option list.

set -eu

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
MANIFEST="$SCRIPT_DIR/models.psv"
SHORTS_MANIFEST="$SCRIPT_DIR/shorts.psv"
SHORTS_WF="$SCRIPT_DIR/shorts/workflows"

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
SORT_SIZE=""
SORT_SIZE_SET=0
ALL_ZIP=0
INSTALL=0
LIST_ONLY=0
SHORTS=0
SHORTS_LIST=0
SHORTS_TYPE="short"
TYPE_SET=0
WITH_H3=0
ACCEPT_H3=0

die() {
    printf 'error: %s\n' "$*" >&2
    exit 2
}

h3_license_notice() {
    cat >&2 <<'EOF'
MiniMax H3 / FastH3 Community License (summary, not legal advice):
  - Use is excluded in the United States, the European Union, the United
    Kingdom, and South Korea.
  - Companies with more than $20M annual revenue need written permission.
  - Commercial products must display "MiniMax H3".
  - Outputs may not be used to train or improve other AI models.
  - Public content must be disclosed as AI-generated.
  Full terms: https://huggingface.co/Comfy-Org/MiniMax-H3
The permissively licensed core (Wan 2.2, SCAIL-2, Z-Image, SeedVR2) does not
require this gate.
EOF
}

usage() {
    cat <<'EOF'
Pixaroma workflow + model installer for ComfyUI

Targets:
  workflows        Extract workflow packs (default: all 40)
  models           Download models used by the selected episodes
  all              Workflows + models
  list             Print the model catalog (no writes)
  shorts           Portrait social media models. Add --install for the shorts
                   workflow pack. No episode selection; use --type instead.

Selection:
  --episode N      Episode number, e.g. 6, 06, Ep06. Repeatable or comma-separated.
  --all            All episodes. Required for `models` when --episode is omitted.
  --sort-size asc|desc
                   Download order by file size. Default is asc (smallest
                   first); use desc for largest first. Applies to models,
                   shorts, and all.

Shorts:
  --short, --shorts  Shorthand for the `shorts` target.
  --install        Also copy shorts/workflows/ into
                   <ComfyUI>/user/default/workflows/Pixaroma/Shorts/.
  --type TYPE      short (default), photo, story, or all.
                   short: portrait video models + upscaler + talking head.
                   photo: Z-Image only, for square/4:5 photo posts.
                   story: Z-Image only, for 9:16 stories and covers.
                   all: every permissively licensed shorts model.
  --with-h3        Add the optional FastH3 models (about 44 GB). Requires
                   --accept-h3-license.
  --accept-h3-license
                   Confirm that you have read the MiniMax H3 Community License.
                   Use is excluded in the USA, EU, UK, and South Korea.
  --list           With --short/--shorts, print the shorts catalog and exit.

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
  --yes            Skip the confirmation prompt for a full `models` or `shorts` install.
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
  ./setup.sh shorts --list
  ./setup.sh shorts --type photo --install --yes --comfyui ~/ComfyUI
  ./setup.sh --short --install --comfyui ~/ComfyUI
  ./setup.sh shorts --type all --with-h3 --accept-h3-license --dry-run

Model files go to <ComfyUI>/models/<folder>/<file> exactly as the workflows expect.
Workflows go to <ComfyUI>/user/default/workflows/Pixaroma/.
Shorts workflows go to <ComfyUI>/user/default/workflows/Pixaroma/Shorts/.
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
        workflows|models|all|list|shorts)
            TARGET=$1
            shift
            ;;
        --short|--shorts)
            SHORTS=1
            shift
            ;;
        --install)
            INSTALL=1
            shift
            ;;
        --type)
            [ $# -ge 2 ] || die "--type needs a value"
            SHORTS_TYPE=$2
            TYPE_SET=1
            shift 2
            ;;
        --type=*)
            SHORTS_TYPE=${1#*=}
            TYPE_SET=1
            shift
            ;;
        --with-h3)
            WITH_H3=1
            shift
            ;;
        --accept-h3-license)
            ACCEPT_H3=1
            shift
            ;;
        --list)
            LIST_ONLY=1
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
        --sort-size)
            [ $# -ge 2 ] || die "--sort-size needs a value (asc or desc)"
            SORT_SIZE=$2
            SORT_SIZE_SET=1
            shift 2
            ;;
        --sort-size=*)
            SORT_SIZE=${1#*=}
            SORT_SIZE_SET=1
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

# Resolve the shorts profile first. --short may appear before or after the target.
if [ "$TARGET" = "shorts" ]; then
    SHORTS=1
fi
if [ "$SHORTS" = 1 ] && [ -z "$TARGET" ]; then
    TARGET=shorts
fi
if [ "$LIST_ONLY" = 1 ]; then
    case "$TARGET" in
        "") TARGET=list ;;
        shorts) TARGET=list; SHORTS_LIST=1 ;;
        list) [ "$SHORTS" = 1 ] && SHORTS_LIST=1 ;;
        *) die "--list cannot be combined with target $TARGET" ;;
    esac
fi
[ -n "$TARGET" ] || { usage; exit 2; }

if [ "$SHORTS" = 1 ] && [ "$TARGET" != "shorts" ] && [ "$TARGET" != "list" ]; then
    die "--short is for the shorts profile; it cannot be combined with target $TARGET"
fi
if [ "$TARGET" = "list" ] && [ "$SHORTS" = 1 ]; then
    SHORTS_LIST=1
fi
if [ "$TARGET" = "shorts" ] || [ "$SHORTS_LIST" = 1 ]; then
    MANIFEST="$SHORTS_MANIFEST"
fi
[ -f "$MANIFEST" ] || die "$(basename -- "$MANIFEST") not found next to this script"

if [ "$SORT_SIZE_SET" = 1 ]; then
    case "$SORT_SIZE" in
        asc|desc) ;;
        *) die "invalid --sort-size: $SORT_SIZE (use asc or desc)" ;;
    esac
    case "$TARGET" in
        models|shorts|all) ;;
        *) die "--sort-size only applies to model downloads" ;;
    esac
fi

if [ "$TARGET" = "shorts" ] || [ "$SHORTS_LIST" = 1 ]; then
    case "$SHORTS_TYPE" in
        short|photo|story|all) ;;
        *) die "invalid --type: $SHORTS_TYPE (use short, photo, story, or all)" ;;
    esac
    [ -z "$EP_SELECTOR" ] || die "--episode is for episode packs; use --type with shorts"
    [ "$ALL" != 1 ] || die "--all is for episode packs; use --type all with shorts"
    [ "$ALL_ZIP" != 1 ] || die "--all-zip is for the episode workflow packs"
    [ "$VERIFY" != 1 ] || [ "$INSTALL" != 1 ] || die "--verify cannot be combined with --install"
    if [ "$WITH_H3" = 1 ]; then
        h3_license_notice
        [ "$ACCEPT_H3" = 1 ] || die "--with-h3 requires --accept-h3-license"
    elif [ "$ACCEPT_H3" = 1 ]; then
        die "--accept-h3-license requires --with-h3"
    fi
else
    [ "$INSTALL" != 1 ] || die "--install is only valid with the shorts profile"
    [ "$TYPE_SET" != 1 ] || die "--type is only valid with the shorts profile"
    [ "$WITH_H3" != 1 ] || die "--with-h3 is only valid with the shorts profile"
    [ "$ACCEPT_H3" != 1 ] || die "--accept-h3-license is only valid with --with-h3"
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

shorts_row_selected() {
    types=$1
    case ",$types," in
        *,h3,*)
            [ "$WITH_H3" = 1 ] || return 1
            return 0
            ;;
    esac
    [ "$SHORTS_TYPE" = "all" ] && return 0
    case ",$types," in
        *",$SHORTS_TYPE,"*) return 0 ;;
        *) return 1 ;;
    esac
}

row_selected() {
    if [ "$TARGET" = "shorts" ] || [ "$SHORTS_LIST" = 1 ]; then
        shorts_row_selected "$1"
        return $?
    fi
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

if { [ "$TARGET" = "workflows" ] || [ "$TARGET" = "all" ] || \
     { [ "$TARGET" = "shorts" ] && [ "$INSTALL" = 1 ]; }; } && [ -z "$COMFY" ]; then
    die "ComfyUI not found. Pass --comfyui /path/to/ComfyUI"
fi

if [ -n "$MODELS_ROOT_ARG" ]; then
    MODELS_DIR=$MODELS_ROOT_ARG
elif [ -n "$COMFY" ]; then
    MODELS_DIR="$COMFY/models"
else
    MODELS_DIR=""
fi

if { [ "$TARGET" = "models" ] || [ "$TARGET" = "shorts" ]; } && [ -z "$MODELS_DIR" ]; then
    die "$TARGET needs --models-root /path/to/models (or a ComfyUI install)"
fi

WF_ROOT="${COMFY:+$COMFY/user/default/workflows/Pixaroma}"

# ---------------------------------------------------------------- archives dir
ARCHIVES="$SCRIPT_DIR/archives"
[ -d "$ARCHIVES" ] || ARCHIVES="$SCRIPT_DIR"

# --------------------------------------------------------------------- listing
if [ "$SHORTS_LIST" = 1 ]; then
    printf '%10s  %-66s %-16s %s\n' "SIZE" "FOLDER/FILE" "TYPES" "SOURCE"
    total=0
    count=0
    h3_count=0
    while IFS='|' read -r folder filename bytes repo repo_path types url gated note; do
        [ "$folder" = "folder" ] && continue
        row_selected "$types" || continue
        count=$((count + 1))
        size=$(human "$bytes")
        total=$((total + bytes))
        case ",$types," in *,h3,*) h3_count=$((h3_count + 1)) ;; esac
        printf '%10s  %-66s %-16s %s\n' "$size" "$folder/$filename" "$types" "$repo"
    done < "$MANIFEST"
    printf '\n%d files selected, %s.' "$count" "$(human "$total")"
    if [ "$h3_count" -gt 0 ]; then
        printf ' %d are optional H3 files under the MiniMax H3 Community License.' "$h3_count"
    else
        printf ' FastH3 is optional; add --with-h3 --accept-h3-license to include it.'
    fi
    printf '\n'
    exit 0
fi

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

shorts_workflow_selected() {
    rel=$1
    case "$rel" in
        "H3 (license-restricted)/"*)
            [ "$WITH_H3" = 1 ]
            ;;
        "Short Video/"*)
            case "$SHORTS_TYPE" in short|all) return 0 ;; *) return 1 ;; esac
            ;;
        "Stories/"*)
            case "$SHORTS_TYPE" in story|all) return 0 ;; *) return 1 ;; esac
            ;;
        "Photo Posts/3."*)
            # 9:16 Z-Image cover/first frame is useful to every shorts type.
            return 0
            ;;
        "Photo Posts/4."*)
            # Social Media Sizes uses no models and is useful everywhere.
            return 0
            ;;
        "Photo Posts/5."*)
            case "$SHORTS_TYPE" in photo|all) return 0 ;; *) return 1 ;; esac
            ;;
        "Photo Posts/"*)
            case "$SHORTS_TYPE" in photo|all) return 0 ;; *) return 1 ;; esac
            ;;
        *)
            return 1
            ;;
    esac
}

install_shorts_workflows() {
    printf '\n== Shorts workflows ==\n'
    [ -d "$SHORTS_WF" ] || die "shorts/workflows not found next to this script"
    dest="$WF_ROOT/Shorts"
    if [ "$DRY" = 1 ]; then
        printf '[dry-run] would copy the shorts workflow pack into %s\n' "$dest"
        find "$SHORTS_WF" -type f | sort | while IFS= read -r file; do
            rel=${file#"$SHORTS_WF"/}
            shorts_workflow_selected "$rel" || continue
            printf '[dry-run] %s\n' "$rel"
        done
        return 0
    fi
    mkdir -p "$dest"
    list=$(mktemp "${TMPDIR:-/tmp}/pixaroma-shorts.XXXXXX") || die "mktemp failed"
    find "$SHORTS_WF" -type f | sort > "$list"
    copied=0
    kept=0
    while IFS= read -r file; do
        rel=${file#"$SHORTS_WF"/}
        shorts_workflow_selected "$rel" || continue
        out="$dest/$rel"
        if [ -f "$out" ] && [ "$FORCE_WORKFLOWS" != 1 ]; then
            kept=$((kept + 1))
            continue
        fi
        mkdir -p "$(dirname -- "$out")"
        cp -f "$file" "$out"
        copied=$((copied + 1))
    done < "$list"
    rm -f "$list"
    total=$(find "$dest" -type f 2>/dev/null | wc -l | tr -d ' ')
    printf '[wf] %d copied, %d kept; %s files in %s\n' "$copied" "$kept" "$total" "$dest"
    [ "$kept" -eq 0 ] || [ "$FORCE_WORKFLOWS" = 1 ] || printf '[wf] existing workflow files were kept (use --force-workflows to overwrite)\n'
}

if [ "$TARGET" = "workflows" ] || [ "$TARGET" = "all" ]; then
    install_workflows
fi

if [ "$TARGET" = "shorts" ] && [ "$INSTALL" = 1 ]; then
    install_shorts_workflows
fi

if [ "$TARGET" = "workflows" ]; then
    exit 0
fi

# --------------------------------------------------------------------- models
if [ "$VERIFY" != 1 ]; then
    command -v hf >/dev/null 2>&1 || die "the 'hf' CLI is not installed (pip install -U \"huggingface_hub[cli]\")"
fi

# Downloads are ordered by the exact manifest byte count, smallest first by
# default. Pre-filter the selected rows into a temporary file so the scan,
# dry-run, and download passes all agree on the order.
[ -n "$SORT_SIZE" ] || SORT_SIZE="asc"
SORTED_ROWS=$(mktemp "${TMPDIR:-/tmp}/pixaroma-rows.XXXXXX") || die "mktemp failed"
trap 'rm -f "$SORTED_ROWS"' 0
if [ "$SORT_SIZE" = "desc" ]; then
    sort_key="-k3,3nr"
else
    sort_key="-k3,3n"
fi
while IFS='|' read -r folder filename bytes repo repo_path eps url gated note; do
    [ "$folder" = "folder" ] && continue
    row_selected "$eps" || continue
    printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' \
        "$folder" "$filename" "$bytes" "$repo" "$repo_path" "$eps" "$url" "$gated" "$note"
done < "$MANIFEST" | sort -t'|' "$sort_key" > "$SORTED_ROWS"
ROWS_SOURCE="$SORTED_ROWS"

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
done < "$ROWS_SOURCE"

if [ "$selected_files" -eq 0 ]; then
    printf 'No model files are referenced by the selected episode(s).\n'
    exit 0
fi

if [ "$TARGET" = "shorts" ]; then
    printf '\n== Shorts models (%s) ==\n' "$SHORTS_TYPE"
else
    printf '\n== Models ==\n'
fi
printf 'Folder:      %s\n' "$MODELS_DIR"
printf 'Selected:    %d files, %s downloadable' "$selected_files" "$(human "$selected_bytes")"
[ "$manual_count" -gt 0 ] && printf ', %d manual' "$manual_count"
printf '\n'
printf 'Present:     %d files (%s)\n' "$present_files" "$(human "$present_bytes")"
printf 'To download: %d files (%s)\n' "$to_fetch_files" "$(human "$to_fetch_bytes")"
[ "$mismatch_files" -gt 0 ] && printf 'Size issues: %d existing file(s) (see warnings above)\n' "$mismatch_files"
[ "$gated_count" -gt 0 ] && printf 'Gated:       %d file(s) require license acceptance + hf auth login\n' "$gated_count"
[ "$WITH_H3" = 1 ] && printf 'H3:          included under the MiniMax H3 Community License\n'

if [ "$VERIFY" = 1 ]; then
    printf '\nVerification only; nothing downloaded.\n'
    [ "$to_fetch_files" -eq 0 ] && [ "$missing_files" -eq 0 ] && [ "$mismatch_files" -eq 0 ] && exit 0
    exit 1
fi

if { [ "$ALL" = 1 ] || [ "$TARGET" = "shorts" ]; } && [ "$DRY" != 1 ] && [ "$YES" != 1 ] && [ "$to_fetch_files" -gt 0 ]; then
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
done < "$ROWS_SOURCE"

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
    done < "$ROWS_SOURCE"
fi

if [ "$failed_files" -gt 0 ] || [ "$gate_skipped" -gt 0 ]; then
    exit 1
fi
exit 0
