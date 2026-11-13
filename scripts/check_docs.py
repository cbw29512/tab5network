#!/usr/bin/env python3
"""Validate repository documentation and enforce progress notes for code PRs.

Schema first: REQUIRED_DOCS is the source inventory; CHANGE_LOGS contains
mandatory state files; SOURCE_PATHS defines when docs must change.
No device, network or firmware access is performed.
"""
from __future__ import annotations

import argparse
import logging
import re
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
REQUIRED_DOCS = (
    "README.md", "PROJECT_STATE.md", "CHANGELOG.md", "CONTRIBUTING.md",
    "SECURITY.md", "docs/DEFINITION_OF_DONE.md", "docs/ARCHITECTURE.md",
    "docs/HARDWARE.md", "docs/SETUP_WINDOWS.md", "docs/FLASH_RECOVERY.md",
    "docs/TEST_PLAN.md", "docs/HANDOFF.md", "docs/DECISIONS.md",
)
CHANGE_LOGS = frozenset(("PROJECT_STATE.md", "CHANGELOG.md"))
SOURCE_PATHS = ("src/", "include/", "components/", "tests/", "scripts/", "firmware/")
SOURCE_CONFIG = frozenset(("platformio.ini", "CMakeLists.txt", "sdkconfig", "idf_component.yml"))
LINK = re.compile(r"\[[^\]]+\]\(([^)]+)\)")
LOG = logging.getLogger("tab5network.docs")


def check_documentation() -> list[str]:
    """Reject missing documentation or broken local markdown links."""
    try:
        errors: list[str] = []
        for relative in REQUIRED_DOCS:
            if not (ROOT / relative).is_file():
                errors.append(f"Missing required documentation: {relative}")
        paths = list(ROOT.glob("*.md")) + list((ROOT / "docs").glob("*.md"))
        for doc in paths:
            for raw in LINK.findall(doc.read_text(encoding="utf-8")):
                url = raw.split("#", 1)[0].strip()
                if not url or "://" in url or url.startswith(("mailto:", "/")):
                    continue
                dest = (doc.parent / url).resolve()
                if not dest.is_file():
                    errors.append(f"Broken local link in {doc.relative_to(ROOT)}: {raw}")
        if errors:
            LOG.error("Documentation integrity: %s problem(s)", len(errors))
        else:
            LOG.info("Documentation integrity check passed (%s markdown files)", len(paths))
        return errors
    except (OSError, UnicodeError) as exc:
        LOG.exception("Unable to read or validate documentation")
        return [f"Documentation check error: {exc}"]


def check_changed_docs(base: str, head: str) -> list[str]:
    """Require living state and change history when application source changes."""
    try:
        result = subprocess.run(
            ["git", "diff", "--name-only", f"{base}...{head}"],
            cwd=ROOT, capture_output=True, text=True, check=True,
        )
        changed = set(result.stdout.splitlines())
        code_changed = any(
            path.startswith(SOURCE_PATHS) or path in SOURCE_CONFIG
            for path in changed
        )
        missing = CHANGE_LOGS - changed if code_changed else set()
        if missing:
            LOG.error("Source changed without updating: %s", ", ".join(sorted(missing)))
            return [f"Update {name} in the same PR as source edits" for name in sorted(missing)]
        LOG.info("Living-document PR gate passed; source changes: %s", code_changed)
        return []
    except (OSError, subprocess.CalledProcessError) as exc:
        LOG.exception("Cannot inspect Git diff to enforce document updates")
        return [f"Git comparison failed: {exc}"]


def main() -> int:
    """Run checks and print actionable failures; no silent pass or device access."""
    try:
        parser = argparse.ArgumentParser(description=__doc__)
        parser.add_argument("--base", help="PR base SHA")
        parser.add_argument("--head", help="PR head SHA")
        args = parser.parse_args()
        errors = check_documentation()
        if bool(args.base) != bool(args.head):
            errors.append("Provide both --base and --head or neither")
        elif args.base and args.head:
            errors.extend(check_changed_docs(args.base, args.head))
        for issue in errors:
            LOG.error("%s", issue)
        return 1 if errors else 0
    except Exception:
        LOG.exception("Unexpected documentation gate error")
        return 2


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO, format="%(levelname)s %(message)s")
    sys.exit(main())
