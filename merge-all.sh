#!/bin/bash

main() {
	local dicts
	local final
	local -i err

	dicts=()
	err=0
	final="data/all.json"

	if ! opt_parse "$@"; then
		return 1
	fi

	for (( i = 1; i < 40; i++)); do
		local kanji
		local tango
		local dict

		kanji="data/kanji$i.json"
		tango="data/tango$i.json"
		dict="data/$i.json"

		if ! [ -e "$kanji" ] ||
		   ! [ -e "$tango" ]; then
			break
		fi

		log_info "Merging $kanji and $tango into $dict"
		if ! ./merge.sh "$kanji" "$tango" > "$dict"; then
			log_error "Could not merge $kanji and $tango into $dict"
			err=1
			continue
		else
			dicts+=("$dict")
		fi
	done

	log_info "Merging ${#dicts[@]} dictionaries into $final"
	if (( ${#dicts[@]} > 0 )); then
		local final_data

		if ! final_data=$(./merge.sh "${dicts[@]}"); then
			log_error "Could not merge combined dictionary"
			err=1
		fi

		if ! printf 'all_questions = %s;\n' "$final_data" > "$final"; then
			log_error "Could not write to $final"
			err=1
		fi
	fi

	return "$err"
}

{
	if ! . toolbox.sh ||
	   ! include "log" "opt"; then
		exit 1
	fi

	main "$@"
	exit "$?"
}
