printf '\nHere is a random entry... \n\n'
jrnl -on "$(jrnl --short | shuf -n 1 | cut -d' ' -f1,2)"