#!/bin/sh
# Script to regenerate en Strings
find . -name \*.m | xargs genstrings -o en.lproj
