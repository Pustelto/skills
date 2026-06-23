#!/bin/bash
# Post an inline review comment to a GitLab MR, anchored to a file + line.
#
# Usage:
#   post-mr-comment.sh <project_id> <mr_iid> <base_sha> <head_sha> \
#                      <file> <new_line> <body_file> [mode]
#
# mode (default "modified"):
#   modified            line was added/changed in this MR (+ line). Sends new_line + old_path.
#   new                 file is newly added in this MR. Sends new_line only, no old_path.
#   context:<old_line>  line is unchanged context. Needs BOTH new_line and old_line.
#   removed:<old_line>  line was removed in this MR (- line). Sends old_line only.
#
# On success, prints: {id, type, has_position, new_line, old_line}
# Verify type == "DiffNote". If it's "DiscussionNote", the position was rejected
# silently and the comment is now an unanchored general note — delete and retry.

set -e

PROJECT_ID="$1"
MR_IID="$2"
BASE_SHA="$3"
HEAD_SHA="$4"
FILE="$5"
NEW_LINE="$6"
BODY_FILE="$7"
MODE="${8:-modified}"

# GitLab requires start_sha; for normal MRs it equals base_sha.
START_SHA="${BASE_SHA}"

case "$MODE" in
  new)
    POSITION=$(jq -n \
      --arg b "$BASE_SHA" --arg h "$HEAD_SHA" --arg s "$START_SHA" \
      --arg p "$FILE" --argjson l "$NEW_LINE" \
      '{base_sha:$b, head_sha:$h, start_sha:$s, position_type:"text", new_path:$p, new_line:$l}')
    ;;
  context:*)
    OLD_LINE="${MODE#context:}"
    POSITION=$(jq -n \
      --arg b "$BASE_SHA" --arg h "$HEAD_SHA" --arg s "$START_SHA" \
      --arg p "$FILE" --argjson n "$NEW_LINE" --argjson o "$OLD_LINE" \
      '{base_sha:$b, head_sha:$h, start_sha:$s, position_type:"text",
        new_path:$p, old_path:$p, new_line:$n, old_line:$o}')
    ;;
  removed:*)
    OLD_LINE="${MODE#removed:}"
    POSITION=$(jq -n \
      --arg b "$BASE_SHA" --arg h "$HEAD_SHA" --arg s "$START_SHA" \
      --arg p "$FILE" --argjson o "$OLD_LINE" \
      '{base_sha:$b, head_sha:$h, start_sha:$s, position_type:"text",
        new_path:$p, old_path:$p, old_line:$o}')
    ;;
  modified|*)
    POSITION=$(jq -n \
      --arg b "$BASE_SHA" --arg h "$HEAD_SHA" --arg s "$START_SHA" \
      --arg p "$FILE" --argjson l "$NEW_LINE" \
      '{base_sha:$b, head_sha:$h, start_sha:$s, position_type:"text",
        new_path:$p, old_path:$p, new_line:$l}')
    ;;
esac

PAYLOAD=$(jq -n --arg body "$(cat "$BODY_FILE")" --argjson position "$POSITION" \
  '{body:$body, position:$position}')

echo "$PAYLOAD" | glab api \
  --method POST \
  --header "Content-Type: application/json" \
  --input - \
  "projects/${PROJECT_ID}/merge_requests/${MR_IID}/discussions" \
  | jq '{id:.id,
         type:.notes[0].type,
         has_position:(.notes[0].position != null),
         new_line:.notes[0].position.new_line,
         old_line:.notes[0].position.old_line}'
