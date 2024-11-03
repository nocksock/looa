#!/bin/sh
exec find . -name "*.lua" -o -name "*_spec.lua" | entr -rc busted --exclude-tags="skip,ignore"
