shopt -s nullglob

export PAGER=cat

for before in munge-failures/*.before.nix; do
	prefix=${before%.before.nix}
	after=$prefix.after.nix
	before_xml=$prefix.before.xml
	after_xml=$prefix.after.xml
	printf '===> %s\n' "$before"
	git diff --no-index --color=always -- "$before" "$after" || true
	printf '\n'
	if [[ -e $before_xml ]]; then
		git diff --no-index --color=always -- "$before_xml" "$after_xml" || true
	else
		grep -E '^(building|Exception:|RuntimeError:) ' "$prefix.after.error" || true
	fi
	printf '\n\n'
done | less -R
