## ~/Dropbox/makefile
## cron: 50 23 * * * make -f /home/minoru/Dropbox/makefile >> /tmp/myjob.log 2>&1
##
## 修正履歴:
## 2026-03-14  dotfiles/gh ターゲットを rsync から git push 方式に移行
# Inherit SSH_AUTH_SOCK from keychain
a.out: git-push


git-push:
	git add . && git diff --cached --exit-code --quiet && echo "\nnothing to commit, working tree clean!"|| \
	git commit -a -m "Updated: `date +'%Y-%m-%d %H:%M:%S'`" && \
	git push origin main
