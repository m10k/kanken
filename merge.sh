#!/bin/bash

main() {
	local files=("$@")

	local file
	local all

	all=()

	for file in "${files[@]}"; do
		local json

		if ! json=$(< "$file"); then
			log_error "Could not read $file"
			return 1
		fi

		while read -r item; do
			all+=("$item")
		done < <(json_array_to_lines "$json")
	done

	json_array "${all[@]}" | jq '.'
}

{
	if ! . toolbox.sh ||
	   ! include "log" "json"; then
		exit 1
	fi

	main "$@"
	exit "$?"
}
