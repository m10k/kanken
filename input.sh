#!/bin/bash

is_in() {
	local str="$1"
	local set="$2"

	local -i idx

	for (( idx = 0; idx < ${#str}; idx++ )); do
		if [[ "$set" != *"${str:$idx:1}"* ]]; then
			return 1
		fi
	done

	return 0
}

is_hiragana() {
	local input="$1"

	local hiragana

	hiragana="あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわゐゑをんがぎぐげござじずぜぞだぢづでどばびぶべぼぱぴぷぺぽぁぃぅぇぉゃゅょっ"

	is_in "$input" "$hiragana"
}

is_katakana() {
	local input="$1"

	local katakana

	katakana="アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヰヱヲンヴガギグゲゴザジズゼゾダヂヅデドバビブベボパピプペポァィゥェォャュョッー"

	is_in "$input" "$katakana"
}

output_kanji_json() {
	local kanji="$1"
	local readings=("${@:2}")

	local yomi

	if (( ${#readings[@]} < 1 )); then
		return 1
	fi

	yomi=$(json_array "${readings[@]}")

	json_object "kanji" "$kanji" \
		    "yomi" "$yomi"
}

read_definition() {
	local input
	local kanji
	local yomi

	kanji=""
	yomi=()

	while read -r -p "漢字または読み[$kanji]: " input; do
		if is_hiragana "$input" ||
		   is_katakana "$input"; then
			log_debug "「$input」は読み方に見える"
		        yomi+=("$input")
		else
			log_debug "「$input」は漢字に見える"
		        kanji="$input"
		fi
	done

	if [[ -z "$kanji" ]] || (( ${#yomi[@]} == 0 )); then
		return 1
	fi

	output_kanji_json "$kanji" "${yomi[@]}"
}

read_definitions() {
	local definitions
	local definition
	local -i num

	definitions=()
	num=1

	printf "\n%d個目の項目:\n" "$num" 1>&2
	while definition=$(read_definition); do
		definitions+=("$definition")
		((num++))
		printf "\n%d個目の項目:\n" "$num" 1>&2
	done

	json_array "${definitions[@]}" | jq '.'
}

generate_json() {
	local input
	local writing
	local readings
	local objects
	local object

	writing=""
	readings=()
	objects=()

	while read -r -p "漢字または読み: " input; do
		if is_hiragana "$input" ||
		   is_katakana "$input"; then
			log_debug "「$input」は読み方に見える"
			readings+=("$input")
		else
			log_debug "「$input」は漢字に見える"
			if [[ -n "$writing" ]]; then
				if ! object=$(output_kanji_json "$writing" "${readings[@]}"); then
					log_error "読み方はない。入力を無視する"
				else
					log_debug "Adding $object to objects"
					objects+=("$object")
				fi

				writing=""
				readings=()
			fi

			writing="$input"
		fi
	done

	if [[ -n "$writing" ]]; then
		if ! object=$(output_kanji_json "$writing" "${readings[@]}"); then
			log_error "読み方はない。入力を無視する"
		else
			log_debug "Adding $object to objects"
			objects+=("$object")
		fi
	fi

	json_array "${objects[@]}" | jq '.'
}

main() {
	local data
	local output

	opt_add_arg "o" "output" "v" "/dev/stdout" "The file to write results to"

	if ! opt_parse "$@"; then
		return 1
	fi

	output=$(opt_get "output")

	if ! data=$(read_definitions); then
		return 1
	fi

	if ! echo "$data" > "$output"; then
		log_error "Could not write to $output"
		return 1
	fi

	printf '\n'

	return 0
}

{
	if ! . toolbox.sh ||
	   ! include "log" "opt" "json"; then
		exit 1
	fi

	main "$@"
	exit "$?"
}
