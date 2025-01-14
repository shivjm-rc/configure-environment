"""Generate an SSH config file for the hosts specified in a JSON file."""

import argparse
import logging
import json
from pathlib import Path
from string import Template

parser = argparse.ArgumentParser(
    description="Generate an SSH config file for the hosts specified in a JSON file. The file should contain an object whose keys are the names of the hosts to define and whose values are objects containing `address`, `user`, `keyFile`, and optionally `port`."
)
parser.add_argument(
    "hosts_file", type=Path, help="JSON file containing host definitions"
)
parser.add_argument(
    "directories_file",
    type=Path,
    help="Per-system mapping of directories to interpolate in identity file paths",
)
parser.add_argument(
    "target", type=str, help="System to retrieve directory mappings for"
)
parser.add_argument(
    "--log",
    type=str,
    help="Logging level",
    default="INFO",
    choices=["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"],
    nargs="?",
)
args = parser.parse_args()

logger = logging.getLogger(__name__)
logging.basicConfig(level=args.log)


def build_host_definition(directories, name, address, user, keyFileTemplate, port=None):
    """Build a single `Host` block."""
    identityFilePath = Template(keyFileTemplate).substitute(directories)
    output = f"""
Host {name}
  HostName {address}
  User {user}
  IdentityFile {identityFilePath}
"""
    if port is not None:
        output += f"  Port {port}"

    return output.strip()


hosts = json.loads(args.hosts_file.read_text())
directories = json.loads(args.directories_file.read_text())
logger.debug("Hosts: %s", hosts)
logger.debug("Directories: %s", directories)
current_directories = directories[args.target]
logger.debug("This system: %s", current_directories)

formatted_hosts = [
    build_host_definition(
        current_directories,
        name,
        h["address"],
        h["user"],
        h["keyFile"],
        h.get("port"),
    )
    for name, h in hosts.items()
]
logger.debug("Formatted hosts: %s", formatted_hosts)

print("\n\n".join(formatted_hosts))
