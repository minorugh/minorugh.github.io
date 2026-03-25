## ~/src/github.com/minorugh/minorugh.github.io/makefile
a.out: git

git:
	git add . && git diff --cached --exit-code --quiet && echo "\nnothing to commit, working tree clean!" || \
	git commit -a -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin main

changelog:
	@DATE=$$(date '+%Y-%m-%d'); \
	TMPFILE=$$(mktemp); \
	printf "## $$DATE\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n---\n\n" > $$TMPFILE; \
	cat CHANGELOG.md >> $$TMPFILE; \
	mv $$TMPFILE CHANGELOG.md; \
	emacsclient CHANGELOG.md

