#!/usr/bin/python
"""KerboScript file utility.

Two modes of operation. The first minifies a given file and writes to output.

> minify_ks.py inputfile.ks outputfile.ks

The second both minifies and concatenates a series of files and writes the
result to an output.

> minify_ks.py --concat inputfile1.ks inputfile2.ks inputfile3.ks outputfil.ks
"""

import re
import sys


def minify(input_file):
    """Remove indentation and comments from a KerboScript file."""

    with open(input_file, 'r') as fh:
        lines = fh.read().split('\n')

    comment = re.compile(r'\s*//.*')
    indent = re.compile(r'^\s+')

    minified_lines = []
    for li in lines:
        li = comment.sub('', li)
        li = indent.sub('', li)
        if li != '':
            minified_lines.append(li)

    return '\n'.join(minified_lines)

def concat(input_strings):
    """Clean up files for concatentation, then join with newlines.

    Removes all but the first lazyglobal commands, and all run commands.
    """
    lazyglobal = re.compile(r'@lazyglobal off\.')
    run = re.compile(r'^\s*run .*?\.')

    output = []
    for index, s in enumerate(input_strings):
        if index > 0:
            s = lazyglobal.sub('', s)
        s = run.sub('', s)
        output.append(s)

    return '\n'.join(output)


if __name__ == "__main__":

    if sys.argv[1] == '--concat' and len(sys.argv) >= 4:
        # Minify several files into one.

        to_minify = sys.argv[2:-1]
        output_file = sys.argv.pop()

        output = concat([minify(f) for f in to_minify])

    elif len(sys.argv) is 3:
        # Minify a single file.

        input_file = sys.argv[1]
        output_file = sys.argv[2]

        output = minify(input_file)

    else:
        print 'Bad arguments. minify_ks.py <inputfile> <outputfile>'
        sys.exit(2)

    with open(output_file, 'w') as fh:
        fh.write(output)
