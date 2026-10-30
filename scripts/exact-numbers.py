#!/usr/bin/env python3
"""Patch the upstream Kupo OpenAPI spec so ledger numbers decode exactly.

Kupo's spec types lovelace, asset quantities and metadata integers as plain
`integer`, which swift-openapi-generator maps to `Swift.Int` (32-bit on
watchOS arm64_32, and too narrow for 2^64-1 token quantities or the full
CBOR metadata integer range). This script points those fields at named
component schemas that `openapi-generator-config.yaml` overrides:

    LedgerQuantity   -> Swift.UInt64       (output lovelace / token quantities)
    MetadatumInteger -> Foundation.Decimal (metadata int, -2^64 ... 2^64-1)
    SlotNo           -> Swift.UInt64       (already a named schema upstream)

Usage:  scripts/exact-numbers.py [SPEC]   (default: Sources/SwiftKupo/openapi.yaml)

The edit is text-based (Python stdlib has no YAML parser), so it navigates
block-style YAML by indentation. It is idempotent: running it on an already
patched spec changes nothing. It fails loudly if the upstream layout moves.
"""

import sys
from pathlib import Path

DEFAULT_SPEC = Path(__file__).resolve().parent.parent / "Sources/SwiftKupo/openapi.yaml"

NEW_SCHEMAS = {
    "LedgerQuantity": [
        "type: integer",
        "description: |",
        "  An output quantity of Lovelace or of some asset (0 ... 2^64-1).",
        "  Overridden to Swift.UInt64 by openapi-generator-config.yaml.",
        "minimum: 0",
        "example: 42",
    ],
    "MetadatumInteger": [
        "type: integer",
        "description: |",
        "  A metadata integer of arbitrary size (CBOR bounds it to -2^64 ... 2^64-1).",
        "  Overridden to Foundation.Decimal by openapi-generator-config.yaml so",
        "  every value in that range decodes exactly.",
        "example: 42",
    ],
}

# property path (under components.schemas) -> schema it should reference
REFS = [
    (["Value", "properties", "coins"], "LedgerQuantity"),
    (["Value", "properties", "assets", "additionalProperties"], "LedgerQuantity"),
    (["Metadatum_Int", "properties", "int"], "MetadatumInteger"),
]


def indent_of(line):
    return len(line) - len(line.lstrip(" "))


def is_content(line):
    s = line.strip()
    return s != "" and not s.startswith("#")


def block_end(lines, start):
    """Index after the last child line of the key at `start`."""
    base = indent_of(lines[start])
    end = start + 1
    last_child = start
    while end < len(lines):
        line = lines[end]
        if is_content(line):
            if indent_of(line) <= base:
                break
            last_child = end
        end += 1
    return last_child + 1


def find_key(lines, start, stop, indent, key):
    for i in range(start, stop):
        line = lines[i]
        if indent_of(line) == indent and line.strip() == f"{key}:" or (
            indent_of(line) == indent and line.strip().startswith(f"{key}: &")
        ):
            return i
    raise SystemExit(f"exact-numbers: key {key!r} not found at indent {indent}")


def locate(lines, path):
    i = find_key(lines, 0, len(lines), 0, "components")
    i = find_key(lines, i + 1, block_end(lines, i), 2, "schemas")
    for key in path:
        parent = i
        child_indent = indent_of(lines[parent]) + 2
        i = find_key(lines, parent + 1, block_end(lines, parent), child_indent, key)
    return i


def patch(text):
    lines = text.split("\n")

    for name, body in NEW_SCHEMAS.items():
        try:
            locate(lines, [name])
            continue  # already present
        except SystemExit:
            pass
        anchor = locate(lines, ["Metadata"])
        block = [f"    {name}:"] + [f"      {b}" if b else "" for b in body] + [""]
        lines[anchor:anchor] = block

    for path, target in REFS:
        i = locate(lines, path)
        child = " " * (indent_of(lines[i]) + 2)
        ref = f'{child}$ref: "#/components/schemas/{target}"'
        lines[i + 1 : block_end(lines, i)] = [ref]

    return "\n".join(lines)


def main():
    spec = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT_SPEC
    original = spec.read_text()
    patched = patch(original)
    if patched != original:
        spec.write_text(patched)
        print(f"exact-numbers: patched {spec}")
    else:
        print(f"exact-numbers: {spec} already patched")


if __name__ == "__main__":
    main()
