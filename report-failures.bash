shopt -s nullglob

export PAGER=cat

for failure in munge-failures/*; do
	before=$failure/before.nix
	after=$failure/after.nix
	before_xml=$failure/before.xml
	after_xml=$failure/after.xml
	printf '===> %s\n' "$failure"
	git diff --no-index --color=always -- "$before" "$after" || true
	printf '\n'
	if [[ -e $before_xml ]]; then
		git diff --no-index --color=always -- "$before_xml" "$after_xml" || true
	else
		printf -- '*** Build failed:\n'
		grep -E \
			'^(building|Exception:|RuntimeError:|       error:) ' \
			"$failure/after.error" \
			|| printf '(unknown error)\n'
	fi
	printf '\n\n\n\n'
done | less -R
