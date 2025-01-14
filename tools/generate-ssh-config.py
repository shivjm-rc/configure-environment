"""Generate an SSH config file for the hosts specified in a JSON file."""

import argparse
import logging
import json
from pathlib import Path
from string import Template

parser = argparse.ArgumentParser(
    description="Generate SSH config files for the hosts specified in a JSON file. The hosts file should contain an object whose keys are the names of the hosts to define and whose values are objects containing `address`, `user`, `keyFile`, and optionally `port`. One config file will be generated for each system defined in `directories`."
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
    "--output_directory",
    type=Path,
    nargs="?",
    default="generated/ssh",
    help="Directory under which to place generated files",
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

for host in directories.keys():
    current_directories = directories[host]
    logger.debug("Directories for %s: %s", host, current_directories)

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

    output_file = args.output_directory / host
    output_text = "\n\n".join(formatted_hosts)
    logger.debug("Writing to %s: %s", output_file, output_text)
    output_file.write_text(output_text)
    logger.info("Wrote %s", output_file)
