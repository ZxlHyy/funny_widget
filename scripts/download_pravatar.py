#!/usr/bin/env python3

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from urllib.error import HTTPError, URLError
from urllib.request import Request, urlopen


BASE_URL = "https://i.pravatar.cc/100?img={}"


def download_image(url: str, dest: Path, timeout: float = 20.0) -> None:
    req = Request(url, headers={"User-Agent": "Mozilla/5.0"})
    with urlopen(req, timeout=timeout) as resp:
        dest.write_bytes(resp.read())


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Download pravatar images 1..100 into your Downloads folder."
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path.home() / "Downloads" / "pravatar_images",
        help="Output directory. Default: ~/Downloads/pravatar_images",
    )
    parser.add_argument(
        "--start",
        type=int,
        default=1,
        help="First image number to download. Default: 1",
    )
    parser.add_argument(
        "--end",
        type=int,
        default=100,
        help="Last image number to download. Default: 100",
    )
    parser.add_argument(
        "--sleep",
        type=float,
        default=0.1,
        help="Seconds to sleep between requests. Default: 0.1",
    )
    args = parser.parse_args()

    output_dir: Path = args.output
    output_dir.mkdir(parents=True, exist_ok=True)

    ok = 0
    failed = 0

    for i in range(args.start, args.end + 1):
        url = BASE_URL.format(i)
        dest = output_dir / f"img_{i}.jpg"
        try:
            download_image(url, dest)
            print(f"saved {dest}")
            ok += 1
        except (HTTPError, URLError, TimeoutError, OSError) as exc:
            print(f"failed {i}: {exc}", file=sys.stderr)
            failed += 1
        if args.sleep > 0:
            time.sleep(args.sleep)

    print(f"done: {ok} saved, {failed} failed")
    return 0 if failed == 0 else 1


if __name__ == "__main__":
    raise SystemExit(main())
