#!/usr/bin/env bash

# Remove agent skill links shared with Claude.
if [[ -d ~/.claude/skills ]]; then
    for skill_directory in ./.agents/skills/*; do
        [[ -d $skill_directory ]] || continue
        skill_directory="$PWD/${skill_directory#./}"

        skill_link=~/.claude/skills/${skill_directory##*/}
        [[ -L $skill_link ]] || continue
        [[ $(readlink "$skill_link") == "$skill_directory" ]] || continue

        [[ -n $DEEZ_VERBOSE ]] && echo "Remove agent skill from Claude: ${skill_directory##*/}."
        rm "$skill_link"
    done
fi
