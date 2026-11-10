#!/usr/bin/env python3
"""Generate human social-media post copy for Pixaroma shorts and photos.

Local-first by design: the only optional model runtime is a local Ollama
instance on 127.0.0.1. There are no cloud calls and no API keys. Without
Ollama, deterministic templates still produce a complete post kit.

Outputs (in --out):
  post.md                 full kit: captions, alt text, hashtags, checklist
  caption.txt             primary caption with hashtags
  alt-text.txt            one alt-text paragraph
  hashtags.txt            hashtag line
  platforms/<name>.txt    one caption per platform, already length-limited
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import re
import sys
import urllib.error
import urllib.request
from pathlib import Path

LOOPBACK_HOSTS = {"127.0.0.1", "localhost", "::1"}
DEFAULT_OLLAMA = "http://127.0.0.1:11434"
DEFAULT_MODELS = ("llama3.2", "qwen2.5", "mistral", "gemma3", "phi4")

TYPE_LABELS = {
    "short": "vertical short video",
    "photo": "photo post",
    "story": "vertical story image",
}
ASPECT_DEFAULT = {"short": "9:16", "photo": "4:5", "story": "9:16"}

STOPWORDS = {
    "a", "an", "and", "are", "as", "at", "be", "but", "by", "for", "from",
    "in", "into", "is", "it", "its", "of", "on", "or", "that", "the", "their",
    "this", "to", "was", "were", "with", "while", "who", "what", "when",
    "where", "why", "how", "my", "your", "our", "very", "just", "about",
    "around", "over", "under", "through", "after", "before", "then", "than",
    "slow", "slowly", "smooth", "soft", "warm", "golden", "cinematic",
    "shot", "video", "vertical", "portrait", "social", "media", "short",
    "small", "large", "little", "big", "new", "old", "good", "bad", "best",
    "worst", "one", "two", "three", "make", "makes", "made", "feel", "feels",
    "look", "looks", "watch", "watching", "moment", "scene", "scenes",
    "shop", "quiet", "very", "really", "just",
}

BASE_TAGS = {
    "short": ["shorts", "reels", "verticalvideo", "aivideo", "creator"],
    "photo": ["photography", "portrait", "aiphoto", "photoftheday", "creator"],
    "story": ["story", "verticalvideo", "aiphoto", "reels", "creator"],
}

PLATFORM_LIMITS = {
    "instagram": 2200,
    "tiktok": 2200,
    "youtube": 5000,
    "facebook": 63206,
    "x": 280,
    "linkedin": 3000,
    "pinterest": 500,
}

PLATFORM_TAGS = {
    "instagram": [],
    "tiktok": [],
    "youtube": ["shorts"],
    "facebook": [],
    "x": [],
    "linkedin": [],
    "pinterest": [],
}


# --------------------------------------------------------------------- helpers
def die(message: str, code: int = 1) -> "NoReturn":
    print(f"error: {message}", file=sys.stderr)
    raise SystemExit(code)


def slugify(text: str, limit: int = 48) -> str:
    slug = re.sub(r"[^a-z0-9]+", "-", text.lower()).strip("-")
    return (slug[:limit].rstrip("-") or "post")


def sentence(text: str) -> str:
    text = " ".join(text.split()).strip()
    if not text:
        return text
    text = text[0].upper() + text[1:]
    if text[-1] not in ".!?":
        text += "."
    return text


def trim(text: str, limit: int) -> str:
    text = " ".join(text.split())
    if len(text) <= limit:
        return text
    cut = text[: limit - 1]
    if " " in cut:
        cut = cut.rsplit(" ", 1)[0]
    return cut.rstrip(" ,;:-") + "…"


def clamp(text: str, limit: int) -> str:
    """Length-limit without destroying paragraph breaks."""
    text = text.strip()
    if len(text) <= limit:
        return text
    cut = text[: limit - 1]
    if " " in cut:
        cut = cut.rsplit(" ", 1)[0]
    return cut.rstrip(" ,;:-") + "…"


def readable_media(paths: list[str]) -> list[str]:
    out = []
    for raw in paths:
        p = Path(raw).expanduser()
        if p.exists():
            out.append(str(p.resolve()))
        else:
            print(f"warning: media not found: {raw}", file=sys.stderr)
            out.append(str(p))
    return out


def keywords(topic: str, limit: int) -> list[str]:
    words = re.findall(r"[A-Za-z0-9]+", topic.lower())
    seen: set[str] = set()
    out: list[str] = []
    for word in words:
        if len(word) < 3 or word in STOPWORDS or word in seen:
            continue
        seen.add(word)
        out.append(word)
        if len(out) >= limit:
            break
    return out


def build_hashtags(topic: str, media_type: str, platforms: list[str], count: int) -> list[str]:
    tags: list[str] = []
    for tag in keywords(topic, max(2, count // 2)) + BASE_TAGS[media_type]:
        if tag not in tags:
            tags.append(tag)
    for platform in platforms:
        for tag in PLATFORM_TAGS.get(platform, []):
            if tag not in tags:
                tags.append(tag)
    return tags[:count]


# -------------------------------------------------------------------- templates
def template_captions(topic: str, media_type: str, tone: str, ctas: list[str]) -> tuple[str, list[str]]:
    subject = sentence(topic).rstrip(".")
    lower = subject[0].lower() + subject[1:] if subject else subject
    label = TYPE_LABELS[media_type]
    hooks = {
        "warm": [
            f"There is something about {lower} that makes the whole day feel lighter.",
            f"A small moment worth keeping: {lower}.",
            f"Some scenes do not need a caption. This one almost did.",
        ],
        "funny": [
            f"POV: you opened your camera roll for five minutes and found {lower}.",
            f"I was going to keep scrolling, but then {lower} happened.",
            f"No thoughts, just {lower} and an unreasonable amount of serotonin.",
        ],
        "bold": [
            f"Stop scrolling. {subject} deserves a closer look.",
            f"This is your sign to pay attention to {lower}.",
            f"Big energy, one {label}, zero wasted frames.",
        ],
        "calm": [
            f"No rush. Just {lower}.",
            f"Breathe in. Watch {lower}. Breathe out.",
            f"Slow down long enough to notice {lower}.",
        ],
        "educational": [
            f"A quick look at {lower}, and why it works.",
            f"Here is what makes {lower} worth a second watch.",
            f"Three things to notice in this {label}: light, movement, and timing.",
        ],
    }
    hooks_for_tone = hooks[tone]
    bodies_by_type = {
        "short": [
            f"This {label} was made for a vertical feed, so the subject stays front and center from the first frame.",
            "Built for sound-off viewing first, with a composition that still reads on a small screen.",
            "The edit keeps the pace tight: one idea, one mood, one reason to watch again.",
        ],
        "photo": [
            "The composition leaves room for on-screen text and a clean crop in the grid.",
            "Natural light does most of the work; the edit stays out of its way.",
            "It holds up as a single post, a carousel cover, or a background for a quote.",
        ],
        "story": [
            "The vertical framing keeps the subject inside the safe zone at the top and bottom.",
            "It is built to be read in one tap, with one idea and no clutter.",
            "The color and negative space leave room for a short line of story text.",
        ],
    }
    bodies = bodies_by_type[media_type]
    primary = f"{hooks_for_tone[0]}\n\n{bodies[0]}\n\n{ctas[0]}"
    alternatives = [
        f"{hooks_for_tone[1]}\n\n{bodies[1]}\n\n{ctas[1]}",
        f"{hooks_for_tone[2]}\n\n{bodies[2]}\n\n{ctas[2]}",
    ]
    return primary, alternatives


def template_alt_text(topic: str, media_type: str, aspect: str) -> str:
    subject = sentence(topic).rstrip(".")
    return (
        f"A {TYPE_LABELS[media_type]} in {aspect} format showing {subject[0].lower() + subject[1:]}. "
        "The subject is centered with clean space around it for on-screen text."
    )


def default_ctas(media_type: str, brand: str | None) -> list[str]:
    tail = f" Follow {brand} for more." if brand else ""
    if media_type == "short":
        return [
            f"Watch it once with sound off, then once with sound on. Save it if the mood lands.{tail}",
            f"Send this to someone who needs a five-second escape.{tail}",
            f"Follow for more small moments like this.{tail}",
        ]
    if media_type == "photo":
        return [
            f"Save this for your next feed post or carousel cover.{tail}",
            f"Which crop would you post first: square or 4:5?{tail}",
            f"Share it with someone whose grid needs this color.{tail}",
        ]
    return [
        f"Tap through, then send it to someone who needs a softer day.{tail}",
        f"Save this story for later; the light is worth coming back to.{tail}",
        f"Follow for more quiet vertical moments.{tail}",
    ]


# ----------------------------------------------------------------------- ollama
def check_loopback(url: str) -> str:
    from urllib.parse import urlparse

    parsed = urlparse(url)
    if parsed.scheme != "http" or parsed.hostname not in LOOPBACK_HOSTS:
        die("--ollama-url must point at a local http://127.0.0.1 or http://localhost instance", 2)
    return url.rstrip("/")


def http_json(url: str, payload: dict | None, timeout: float) -> dict:
    data = None
    headers = {"Accept": "application/json"}
    if payload is not None:
        data = json.dumps(payload).encode("utf-8")
        headers["Content-Type"] = "application/json"
    request = urllib.request.Request(url, data=data, headers=headers)
    with urllib.request.urlopen(request, timeout=timeout) as response:
        body = response.read().decode("utf-8", "replace")
    return json.loads(body)


def ollama_model(base: str, requested: str | None, timeout: float) -> str | None:
    try:
        tags = http_json(f"{base}/api/tags", None, timeout)
    except (urllib.error.URLError, OSError, ValueError):
        return None
    installed = [m.get("name", "") for m in tags.get("models", []) if m.get("name")]
    if requested:
        for name in installed:
            if name == requested or name.split(":", 1)[0] == requested:
                return name
        return None
    for preferred in DEFAULT_MODELS:
        for name in installed:
            if name == preferred or name.split(":", 1)[0] == preferred:
                return name
    return installed[0] if installed else None


def ollama_copy(
    base: str,
    model: str,
    topic: str,
    media_type: str,
    tone: str,
    platforms: list[str],
    count: int,
    timeout: float,
) -> dict | None:
    prompt = f"""You write social media post copy. Reply with strict JSON only.
Keys:
  primary: string, the main caption, 2-4 short sentences, human and specific
  alternatives: array of exactly 2 different captions, same topic
  alt_text: one factual sentence describing the media for a blind viewer
  hashtags: array of lowercase hashtag words without the # symbol

Topic: {topic}
Media: {TYPE_LABELS[media_type]}
Tone: {tone}
Platforms: {", ".join(platforms)}
Hashtag count: {count}

Rules:
- Do not invent brand names, prices, locations, or claims that are not in the topic.
- No emojis unless the tone is funny; then at most two.
- Do not start with "In this video" or "This image shows".
- Write like a person, not an ad agency.
- Keep the primary caption under 600 characters.
"""
    payload = {
        "model": model,
        "prompt": prompt,
        "stream": False,
        "format": "json",
        "options": {"temperature": 0.7, "num_predict": 500},
    }
    try:
        result = http_json(f"{base}/api/generate", payload, timeout)
        parsed = json.loads(result.get("response", ""))
    except (urllib.error.URLError, OSError, ValueError, json.JSONDecodeError):
        return None
    primary = parsed.get("primary")
    alternatives = parsed.get("alternatives")
    alt_text = parsed.get("alt_text")
    tags = parsed.get("hashtags")
    if not isinstance(primary, str) or not primary.strip():
        return None
    if not isinstance(alternatives, list):
        alternatives = []
    if not isinstance(alt_text, str) or not alt_text.strip():
        alt_text = None
    if not isinstance(tags, list):
        tags = []
    cleaned_tags = []
    for tag in tags:
        if not isinstance(tag, str):
            continue
        tag = re.sub(r"[^a-z0-9]", "", tag.lower().lstrip("#"))
        if tag and tag not in cleaned_tags:
            cleaned_tags.append(tag)
    return {
        "primary": primary.strip(),
        "alternatives": [a.strip() for a in alternatives if isinstance(a, str) and a.strip()][:2],
        "alt_text": alt_text.strip() if alt_text else None,
        "hashtags": cleaned_tags[:count],
    }


# ------------------------------------------------------------------ platform copy
def platform_copy(
    platform: str,
    primary: str,
    topic: str,
    media_type: str,
    hashtags: list[str],
    link: str | None,
) -> str:
    tags = " ".join("#" + t for t in hashtags)
    body = primary
    if platform == "instagram":
        body = f"{primary}\n\n{tags}"
    elif platform == "tiktok":
        short_tags = " ".join("#" + t for t in hashtags[:5])
        body = f"{primary}\n\n{short_tags}"
    elif platform == "youtube":
        body = f"{primary}\n\n{tags}"
        if "#shorts" not in body.lower():
            body += "\n\n#Shorts"
    elif platform == "facebook":
        body = primary
        if link:
            body += f"\n\n{link}"
    elif platform == "x":
        short_tags = " ".join("#" + t for t in hashtags[:2])
        room = max(80, 280 - len(short_tags) - 2)
        body = clamp(" ".join(primary.split()), room).rstrip() + " " + short_tags
    elif platform == "linkedin":
        body = primary
        if link:
            body += f"\n\n{link}"
        body += "\n\n" + " ".join("#" + t for t in hashtags[:4])
    elif platform == "pinterest":
        body = clamp(f"{primary} {tags}", 500)
    limit = PLATFORM_LIMITS.get(platform, 2200)
    return clamp(body, limit)


# ------------------------------------------------------------------------ output
def write_outputs(
    out_dir: Path,
    topic: str,
    media_type: str,
    aspect: str,
    tone: str,
    platforms: list[str],
    media: list[str],
    backend: str,
    primary: str,
    alternatives: list[str],
    alt_text: str,
    hashtags: list[str],
    link: str | None,
    disclose: bool,
) -> None:
    out_dir.mkdir(parents=True, exist_ok=True)
    tag_line = " ".join("#" + t for t in hashtags)
    caption = primary.strip()
    if tag_line:
        caption += "\n\n" + tag_line
    if disclose:
        caption += "\n\nAI-generated media."

    (out_dir / "caption.txt").write_text(caption + "\n", encoding="utf-8")
    (out_dir / "alt-text.txt").write_text(alt_text.strip() + "\n", encoding="utf-8")
    (out_dir / "hashtags.txt").write_text(tag_line + "\n", encoding="utf-8")

    platform_dir = out_dir / "platforms"
    platform_dir.mkdir(exist_ok=True)
    for platform in platforms:
        text = platform_copy(platform, primary, topic, media_type, hashtags, link)
        if disclose:
            text = clamp(text, PLATFORM_LIMITS.get(platform, 2200) - 20) + "\n\nAI-generated media."
        (platform_dir / f"{platform}.txt").write_text(text.strip() + "\n", encoding="utf-8")

    media_inline = ", ".join(f"`{path}`" for path in media) or "(none supplied)"
    alt_blocks = "\n\n".join(f"{i}. {a}" for i, a in enumerate(alternatives, 1)) or "1. (none)"
    checklist = """- [ ] Watch or read the media once with sound off.
- [ ] Check the first frame or thumbnail; it is the scroll-stopper.
- [ ] Confirm platform limits and link previews.
- [ ] Add music in your editor if the clip is silent.
- [ ] Add an AI-generated disclosure where the platform or model license requires it.
- [ ] Keep the original file; upload the highest-quality copy the platform allows."""
    if media_type == "short":
        checklist += "\n- [ ] Add captions or on-screen text for sound-off viewers."
    if media_type == "photo":
        checklist += "\n- [ ] Pick the crop that matches the platform (4:5 feed, 1:1 grid)."
    if media_type == "story":
        checklist += "\n- [ ] Keep the subject out of the top and bottom UI zones."

    doc = f"""# Post copy — {sentence(topic).rstrip('.')}

- **Type:** {TYPE_LABELS[media_type]} ({aspect})
- **Tone:** {tone}
- **Platforms:** {", ".join(platforms)}
- **Generated:** {_dt.date.today().isoformat()}
- **Copy source:** {backend}
- **Media:** {media_inline}

## Primary caption

{primary.strip()}

{tag_line}

## Alternative captions

{alt_blocks}

## Alt text

{alt_text.strip()}

## Hashtags

{tag_line}

## Platform versions

"""
    for platform in platforms:
        text = platform_copy(platform, primary, topic, media_type, hashtags, link)
        doc += f"### {platform.capitalize()}\n\n{text.strip()}\n\n"
    doc += f"""## Publishing checklist

{checklist}

---

Generated locally by `shorts_post.py`. Templates work offline; `--ollama` uses a
local Ollama model only. Review before posting: you are responsible for factual
claims, music rights, and any license-required AI disclosure.
"""
    (out_dir / "post.md").write_text(doc, encoding="utf-8")


# -------------------------------------------------------------------------- main
def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        prog="shorts-post",
        description="Generate local social-media post copy for Pixaroma media.",
    )
    parser.add_argument("--topic", help="what the media is about")
    parser.add_argument("--brief", type=Path, help="read the topic from a text file")
    parser.add_argument("--type", choices=sorted(TYPE_LABELS), default="short", dest="media_type")
    parser.add_argument("--aspect", choices=["9:16", "4:5", "1:1", "16:9"], help="frame shape; defaults by type")
    parser.add_argument(
        "--platform",
        action="append",
        default=[],
        help="repeatable or comma-separated: instagram, tiktok, youtube, facebook, x, linkedin, pinterest",
    )
    parser.add_argument(
        "--tone",
        choices=["warm", "funny", "bold", "calm", "educational"],
        default="warm",
    )
    parser.add_argument("--hashtags", type=int, default=8, help="number of hashtags (default 8)")
    parser.add_argument("--media", action="append", default=[], help="media file; repeatable")
    parser.add_argument("--out", type=Path, help="output folder")
    parser.add_argument("--brand", help='handle or name for the call to action, e.g. "@pixaroma"')
    parser.add_argument("--link", help="link to include on Facebook and LinkedIn")
    parser.add_argument("--disclose", action="store_true", help='append "AI-generated media." to captions')
    parser.add_argument("--ollama", action="store_true", help="require local Ollama; fail if unavailable")
    parser.add_argument("--no-ollama", action="store_true", help="use templates only")
    parser.add_argument("--ollama-url", default=DEFAULT_OLLAMA, help="local Ollama base URL")
    parser.add_argument("--model", help="Ollama model name; defaults to the first good local match")
    parser.add_argument("--timeout", type=float, default=90.0, help="Ollama timeout in seconds")
    args = parser.parse_args(argv)

    if args.ollama and args.no_ollama:
        parser.error("--ollama and --no-ollama are mutually exclusive")
    if not args.topic and not args.brief:
        parser.error("provide --topic or --brief")
    if args.brief:
        try:
            args.topic = args.brief.read_text(encoding="utf-8").strip()
        except OSError as exc:
            parser.error(f"cannot read --brief: {exc}")
    if not args.topic or not args.topic.strip():
        parser.error("the topic is empty")
    if args.hashtags < 0 or args.hashtags > 30:
        parser.error("--hashtags must be between 0 and 30")

    raw_platforms: list[str] = []
    for item in args.platform:
        for part in item.split(","):
            part = part.strip().lower()
            if not part:
                continue
            if part == "twitter":
                part = "x"
            if part not in PLATFORM_LIMITS:
                parser.error(f"unknown platform: {part}")
            if part not in raw_platforms:
                raw_platforms.append(part)
    if not raw_platforms:
        raw_platforms = ["instagram"] if args.media_type == "photo" else ["instagram", "tiktok", "youtube"]
    args.platforms = raw_platforms
    args.aspect = args.aspect or ASPECT_DEFAULT[args.media_type]
    return args


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    topic = " ".join(args.topic.split())
    platforms: list[str] = args.platforms
    media = readable_media(args.media)
    hashtags = build_hashtags(topic, args.media_type, platforms, args.hashtags)

    backend = "local templates"
    generated: dict | None = None
    if not args.no_ollama:
        base = check_loopback(args.ollama_url)
        model = ollama_model(base, args.model, args.timeout)
        if model:
            generated = ollama_copy(
                base, model, topic, args.media_type, args.tone, platforms, args.hashtags, args.timeout
            )
            if generated:
                backend = f"local Ollama ({model})"
            elif args.ollama:
                die(f"Ollama is running but model {args.model or '(auto)'} did not return usable JSON", 1)
            else:
                print("note: Ollama was reachable but returned no usable copy; using templates", file=sys.stderr)
        elif args.ollama:
            die("no usable local Ollama model found; pull one or use --no-ollama", 1)

    ctas = default_ctas(args.media_type, args.brand)
    if generated:
        primary = generated["primary"]
        alternatives = generated["alternatives"]
        if len(alternatives) < 2:
            fallback_primary, fallback_alts = template_captions(topic, args.media_type, args.tone, ctas)
            for alt in fallback_alts:
                if len(alternatives) >= 2:
                    break
                if alt not in alternatives:
                    alternatives.append(alt)
        alt_text = generated["alt_text"] or template_alt_text(topic, args.media_type, args.aspect)
        if generated["hashtags"]:
            hashtags = generated["hashtags"]
    else:
        primary, alternatives = template_captions(topic, args.media_type, args.tone, ctas)
        alt_text = template_alt_text(topic, args.media_type, args.aspect)

    out_dir = args.out
    if out_dir is None:
        base_dir = Path.cwd() / "shorts-posts"
        out_dir = base_dir / slugify(topic)
        counter = 2
        while out_dir.exists():
            out_dir = base_dir / f"{slugify(topic)}-{counter}"
            counter += 1
    out_dir = out_dir.expanduser()

    write_outputs(
        out_dir,
        topic,
        args.media_type,
        args.aspect,
        args.tone,
        platforms,
        media,
        backend,
        primary,
        alternatives,
        alt_text,
        hashtags,
        args.link,
        args.disclose,
    )

    print(f"copy source: {backend}")
    print(f"output: {out_dir.resolve()}")
    for name in ("post.md", "caption.txt", "alt-text.txt", "hashtags.txt"):
        print(f"  {name}")
    for platform in platforms:
        print(f"  platforms/{platform}.txt")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
