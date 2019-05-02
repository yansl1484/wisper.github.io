echo "-------------updating blog--------------"
hexo clean && hexo g && gulp build && hexo d -g
echo "--------------update success--------------"
