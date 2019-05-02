git checkout hexo
echo "-------------backup--------------"
time=$(date "+%Y-%m-%d %H:%M:%S")
git add . && git commit -m "backup at ${time}" && git push origin hexo
echo "--------------backup success--------------"
