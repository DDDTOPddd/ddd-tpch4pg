#!/usr/bin/env python3
import argparse
import datetime as dt
import random
import re
from pathlib import Path

REGIONS = ["AFRICA", "AMERICA", "ASIA", "EUROPE", "MIDDLE EAST"]
NATIONS = [
    "ALGERIA", "ARGENTINA", "BRAZIL", "CANADA", "EGYPT",
    "ETHIOPIA", "FRANCE", "GERMANY", "INDIA", "INDONESIA",
    "IRAN", "IRAQ", "JAPAN", "JORDAN", "KENYA",
    "MOROCCO", "MOZAMBIQUE", "PERU", "CHINA", "ROMANIA",
    "SAUDI ARABIA", "VIETNAM", "RUSSIA", "UNITED KINGDOM", "UNITED STATES",
]
MKT_SEGMENTS = ["AUTOMOBILE", "BUILDING", "FURNITURE", "HOUSEHOLD", "MACHINERY"]
SHIP_MODES = ["AIR", "AIR REG", "FOB", "MAIL", "RAIL", "REG AIR", "SHIP", "TRUCK"]
PART_TYPES = [
    "STANDARD ANODIZED TIN",
    "STANDARD BURNISHED COPPER",
    "SMALL PLATED BRASS",
    "SMALL ANODIZED NICKEL",
    "MEDIUM POLISHED TIN",
    "MEDIUM BRUSHED STEEL",
    "LARGE POLISHED COPPER",
    "LARGE ANODIZED STEEL",
    "ECONOMY ANODIZED STEEL",
    "PROMO BURNISHED COPPER",
]

TOKEN_RE = re.compile(r"\[([A-Z0-9_]+)(?::([^\]]+))?\]")


def random_month_start(rng: random.Random, start: dt.date, end: dt.date) -> dt.date:
    months = (end.year - start.year) * 12 + (end.month - start.month)
    offset = rng.randint(0, months)
    year = start.year + (start.month - 1 + offset) // 12
    month = (start.month - 1 + offset) % 12 + 1
    return dt.date(year, month, 1)


def random_date(rng: random.Random, start: dt.date, end: dt.date) -> dt.date:
    delta_days = (end - start).days
    return start + dt.timedelta(days=rng.randint(0, max(delta_days, 0)))


def resolve_token(name: str, args: str | None, rng: random.Random, scale: int) -> str:
    if name == "SEED":
        return str(getattr(rng, "seed_value", ""))

    if name == "SCALE":
        return str(scale)

    if name == "DATE_1":
        d = random_month_start(rng, dt.date(1993, 1, 1), dt.date(1997, 10, 1))
        return d.isoformat()

    if name == "DATE_2":
        d = random_date(rng, dt.date(1992, 1, 1), dt.date(1998, 12, 31))
        return d.isoformat()

    if name == "ORDER_DATE_START":
        d = random_date(rng, dt.date(1993, 1, 1), dt.date(1997, 12, 1))
        return d.isoformat()

    if name == "REGION":
        return rng.choice(REGIONS)

    if name == "NATION":
        return rng.choice(NATIONS)

    if name == "MKT_SEGMENT":
        return rng.choice(MKT_SEGMENTS)

    if name == "SHIPMODE":
        return rng.choice(SHIP_MODES)

    if name == "PART_TYPE":
        return rng.choice(PART_TYPES)

    if name == "PART_SIZE":
        return str(rng.randint(1, 50))

    if name == "TOP_K_SMALL":
        return str(rng.choice([1, 3, 5, 10]))

    if name == "LIMIT_N":
        base = [20, 50, 100, 200, 500]
        if scale >= 10:
            base.extend([1000, 2000])
        return str(rng.choice(base))

    if name == "DISCOUNT_LOW":
        low = rng.randint(2, 8)
        return f"0.{low:02d}"

    if name == "DISCOUNT_HIGH":
        high = rng.randint(9, 12)
        return f"0.{high:02d}"

    if name == "RAND_INT":
        if not args:
            raise ValueError("[RAND_INT] requires args like [RAND_INT:1:10]")
        parts = args.split(":")
        if len(parts) != 2:
            raise ValueError("[RAND_INT] args format must be min:max")
        lo, hi = int(parts[0]), int(parts[1])
        return str(rng.randint(lo, hi))

    if name == "RAND_CHOICE":
        if not args:
            raise ValueError("[RAND_CHOICE] requires args like [RAND_CHOICE:A|B|C]")
        options = [x for x in args.split("|") if x]
        if not options:
            raise ValueError("[RAND_CHOICE] options cannot be empty")
        return rng.choice(options)

    raise ValueError(f"Unknown token: [{name}{':' + args if args else ''}]")


def render_template(text: str, rng: random.Random, scale: int) -> str:
    cache: dict[str, str] = {}

    def resolve_cached(name: str, args: str | None) -> str:
        key = f"{name}:{args or ''}"

        # 保证同一 SQL 内重复占位符一致，避免窗口条件错位。
        if name in {
            "DATE_1",
            "DATE_2",
            "REGION",
            "NATION",
            "MKT_SEGMENT",
            "SHIPMODE",
            "PART_TYPE",
            "PART_SIZE",
            "TOP_K_SMALL",
            "LIMIT_N",
            "DISCOUNT_LOW",
            "DISCOUNT_HIGH",
            "ORDER_DATE_START",
        }:
            if key not in cache:
                cache[key] = resolve_token(name, args, rng, scale)
            return cache[key]

        if name == "ORDER_DATE_END":
            start_key = "ORDER_DATE_START:"
            if start_key not in cache:
                cache[start_key] = resolve_token("ORDER_DATE_START", None, rng, scale)

            start_date = dt.date.fromisoformat(cache[start_key])
            end_date = start_date + dt.timedelta(days=rng.randint(30, 365))
            return end_date.isoformat()

        return resolve_token(name, args, rng, scale)

    def repl(match: re.Match[str]) -> str:
        name = match.group(1)
        args = match.group(2)
        return resolve_cached(name, args)

    return TOKEN_RE.sub(repl, text)


def main() -> int:
    parser = argparse.ArgumentParser(description="Render custom TPCH SQL templates with token replacement")
    parser.add_argument("--template", required=True, help="Path to template SQL file")
    parser.add_argument("--output", required=True, help="Path to output SQL file")
    parser.add_argument("--seed", required=True, type=int, help="Random seed")
    parser.add_argument("--scale", required=True, type=int, help="Scale factor, e.g. 1 or 10")
    args = parser.parse_args()

    template_path = Path(args.template)
    output_path = Path(args.output)

    if not template_path.exists():
        raise FileNotFoundError(f"Template not found: {template_path}")

    source = template_path.read_text(encoding="utf-8")
    rng = random.Random(args.seed + args.scale * 100000)
    rng.seed_value = args.seed
    rendered = render_template(source, rng, args.scale)

    header = f"-- custom seed: {args.seed}, scale: {args.scale}\n"
    output_path.parent.mkdir(parents=True, exist_ok=True)
    output_path.write_text(header + rendered.rstrip() + "\n", encoding="utf-8")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
