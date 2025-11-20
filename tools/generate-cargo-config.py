# /// script
# dependencies = ["Jinja2"]
# ///

import argparse
from pathlib import Path

from jinja2 import Environment

BASE_DIR = Path(__file__).parent.parent

parser = argparse.ArgumentParser("Generate cargo.toml from template")
parser.add_argument("build_dir", type=Path, help="directory to build Rust code in")
parser.add_argument(
    "--template",
    type=Path,
    nargs="?",
    default=Path(BASE_DIR / "files" / "cargo-config.toml.j2"),
)
args = parser.parse_args()


env = Environment()
template = env.from_string(args.template.read_text(encoding="utf-8"))
config = template.render({"rust_build_directory": args.build_dir.as_posix()})

print(config)
