"""
Command-line interface for my-package
"""

import argparse
from .core import hello_world, greet


def main():
    """
    Main entry point for the command-line interface.
    """
    parser = argparse.ArgumentParser(
        description="My Package - A simple Hello World application"
    )
    parser.add_argument(
        "--name",
        type=str,
        help="Name to greet (optional)",
        default=None
    )
    parser.add_argument(
        "--version",
        action="store_true",
        help="Show version information"
    )
    
    args = parser.parse_args()
    
    if args.version:
        from . import __version__
        print(f"my-package version {__version__}")
        return
    
    if args.name:
        message = greet(args.name)
        print(message)
    else:
        hello_world()


if __name__ == "__main__":
    main()
