#!/bin/bash

Help() {
	echo "Fetch and display xkcd comics"
	echo
	echo "Syntax: xkcd [-h|n]"
	echo "Options:"
	echo "n    specify the comic number, set to 0 to fetch the most recent"
	echo "h    print help"
	echo
	echo "Run without options to fetch from the recent feed"
	echo
}

Display() {
	echo "$1 - $2" # 1: number, 2: title
	curl -sL "$3" | chafa - # 3: image URL
	echo "$4" # 4: Alt text
}

Fetch() {
	JSON=$(curl -s "$1")
	number=$(jq -r '.num' <<< "$JSON")
	title=$(jq -r '.title' <<< "$JSON")
	image_small=$(jq -r '.img' <<< "$JSON")
	image=$(Image "$image_small")
	text=$(jq -r '.alt' <<< "$JSON")
	Display "$number" "$title" "$image" "$text"
}

Image(){
	image_small="$1"
	image=${image_small//.png/_2x.png}
	if ! curl -sIL "$image" | grep -q "HTTP/.* 200"; then
		image="$image_small"
	fi
	echo "$image"
}

while getopts ":hrn:" option; do
   case $option in
      h)
        Help
        exit;;
      n)
      	if [[ "$OPTARG" =~ ^[1-9][0-9]*$ ]]; then
      		number="$OPTARG"
      		URL="https://xkcd.com/$number/info.0.json"
      	elif [[ "$OPTARG" == 0 ]]; then
      		URL="https://xkcd.com/info.0.json"
      	else
			echo "Error: Invalid argument for -n: '$OPTARG'" >&2
			exit 1
      	fi
      	Fetch "$URL"
      	exit;;
     \?)
        echo "Error: Invalid option" >&2
        exit 1;;
   esac
done

feed=$(curl -s https://xkcd.com/atom.xml)
if [[ -z "$feed" ]]; then
    echo "Error: Failed to get feed" >&2
    exit 1
fi

formatted_xml=$(xmllint --format - <<< "$feed")

entries=$(xmllint --xpath "//*[local-name()='feed']/*[local-name()='entry']" - <<<"$formatted_xml")

mapfile -t titles < <(xmllint --xpath "//*[local-name()='feed']/*[local-name()='entry']/*[local-name()='title']/text()" - <<<"$formatted_xml")

echo 'Select an option:'
select title in "${titles[@]}"
do
	if [[ -n "$title" ]]; then
		entry=$(xmllint --xpath "//*[local-name()='feed']/*[local-name()='entry'][*[local-name()='title' and text()='$title']]" - <<<"$formatted_xml")
		permalink=$(xmllint --xpath "//*[local-name()='entry']/*[local-name()='id']/text()" - <<<"$entry")
		
		image_small=$(grep -oP 'src="\K[^"]+' <<<"$entry")
		
		number=$(grep -oP '.com/\K[^/]+' <<<"$permalink")
		text=$(grep -oP 'alt="\K[^"]+' <<<"$entry")
		#image=${image_small//.png/_2x.png}

		image=$(Image "$image_small")

		Display "$number" "$title" "$image" "$text"
		
		#echo "$number - $title"
		#curl -sL "$image" | chafa -
		#echo "$text"
		
		break
	else
		echo "Error: Invalid option." >&2
	fi
done
