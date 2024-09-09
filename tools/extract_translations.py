#!/usr/bin/env python3

from argparse import ArgumentParser, FileType
from pathlib import Path
import os, re, sys


class ParseError(ValueError):
    pass


def get_args(argv=None):
    parser = ArgumentParser(
        description="Extract translations of given string as GDScript dictionary"
    )
    parser.add_argument("string", help="String to extract translations for")
    parser.add_argument("translations_dir", type=existing_dir_path,
                        help="Directory containing .po files with translations")
    parser.add_argument("--output", "-o", type=FileType("w"), default="-",
                        help="File to write the resulting dict to. Default is to print to stdout")

    return parser.parse_args(argv)


def printerr(msg, *args):
    print(msg, *args, file=sys.stderr)


def existing_dir_path(path):
    path = Path(path)
    if not path.is_dir():
        raise ValueError(f"{path} is not a valid directory")
    return path

def extract_single(path, string):
    regex = re.compile(f'^ *msgid +"{string}".*')
    found = False
    for line in path.read_text().splitlines():
        if found:
            match = re.match('^ *msgstr +"(.*)" *$', line)
            if not match:
                printerr(f"Malformed po file '{path}'")
                raise ParseError()
            return match.group(1)
        if regex.match(line):
            found = True
    printerr(f"Translation not found in '{path}'")


def main(argv=None):
    args = get_args(argv)
    translations = {}
    for po_file in args.translations_dir.glob("*.po"):
        locale = po_file.stem
        translation = extract_single(po_file, args.string)
        if translation:
            translations[locale] = translation

    # Can't use pprint because it forces backslash escapes in some strings instead of just
    # printing characters as they appear
    print("{", file=args.output)
    for locale, string in translations.items():
        print(f'    "{locale}": "{string}",', file=args.output)
    print("}", file=args.output)
        
    return translations

if __name__ == "__main__":
    translations = main()
