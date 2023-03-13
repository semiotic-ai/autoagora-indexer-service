#!/usr/bin/env python3

# Don't forget to `chmod +x` this file.
# Then call it like this:
#
# $ ./version_list_diff.py '["a", "b", "c"]' '["v0.0.1-b"]' '0.0.1'
# ['a', 'c']
#

import sys
import json
import os

# Check if three arguments were provided
if len(sys.argv) != 4:
    raise RuntimeError("Please provide two square bracket lists and a string as input arguments.")

# Get the input lists from command line arguments
indexer_packages_list_raw = sys.argv[1]
ag_packages_list_raw = sys.argv[2]
version = sys.argv[3]

# If version is empty -- return all tags
if not version:
    print(indexer_packages_list_raw)
    exit(0)

# Parse the input lists into Python lists
indexer_packages_list = json.loads(indexer_packages_list_raw)
assert isinstance(indexer_packages_list, list)
ag_packages_list = json.loads(ag_packages_list_raw)
assert isinstance(ag_packages_list, list)

assert isinstance(version, str)

# Filter out tags that aren't in packages when mapped to "v{version}-{tag}"
matching_tags = [tag for tag in indexer_packages_list if f"v{version}-{tag}" not in ag_packages_list]

# Print the matching tags to stdout
print(json.dumps(matching_tags))