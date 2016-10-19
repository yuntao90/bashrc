
if [ -n "$(git tag | grep android-6.0.0_r1)" ] ; then
echo dumping $(printenv REPO_PATH)
git log android-6.0.0_r1...aosp/master --pretty="%H_TAGTAB_%ae_TAGTAB_\"%s\"_TAGTAB_$(printenv REPO_PATH)" | sed -e "s?_TAGTAB_?\t?g" >> $HOME/all_commits_mm_trunk.info
fi
