# docs/makefile
a.out: deploy

deploy:
	cd ~/src/github.com/minorugh/minorugh.github.io && \
	git add . && git diff --cached --exit-code --quiet && \
	echo "\nnothing to commit, working tree clean!" || \
	git commit -a -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin main
	google-chrome https://minorugh.github.io


