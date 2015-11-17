#!/usr/bin/python

import re
import sys


def minify(input_file, output_file):
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

    with open(output_file, 'w') as fh:
        fh.write('\n'.join(minified_lines))


if __name__ == "__main__":
    if len(sys.argv) is not 3:
        print 'Bad arguments. minify_ks.py <inputfile> <outputfile>'
        sys.exit(2)

    minify(sys.argv[1], sys.argv[2])
