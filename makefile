## ~/src/github.com/minorugh/minorugh.github.io/makefile
a.out: git

git:
	git add . && git diff --cached --exit-code --quiet && echo "\nnothing to commit, working tree clean!" || \
	git commit -a -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin main
	google-chrome https://github.com/minorugh/minorugh.github.io/blob/main/CHANGELOG.md

changelog:
	@DATE=$$(date '+%Y-%m-%d'); \
	TMPFILE=$$(mktemp); \
	printf "## $$DATE\n\n### Added\n\n### Changed\n\n### Fixed\n\n### Removed\n\n---\n\n" > $$TMPFILE; \
	cat CHANGELOG.md >> $$TMPFILE; \
	mv $$TMPFILE CHANGELOG.md; \
	emacsclient CHANGELOG.md

log:
	git log --oneline -20

cat:
	cat CHANGELOG.md

view:
	google-chrome https://github.com/minorugh/minorugh.github.io/blob/main/CHANGELOG.md

commits:
	google-chrome https://github.com/minorugh/minorugh.github.io/commits/main

actions:
	google-chrome https://github.com/minorugh/minorugh.github.io/actions
