#!/bin/bash

# ⚠️ USE WITH EXTREME CARE ⚠️
change ()
{
  NEW_NAME=$1
  NEW_MAIL=$2
  OLD_MAIL=$3
  cat <<EOF > my-mailmap
$NEW_NAME <$NEW_MAIL> <$OLD_MAIL>
EOF
  echo my-mailmap content is \(syntax NEW_NAME NEW_MAIL OLD_MAIL\):
  echo $(< my-mailmap)
  echo "Continue to git filter-repo? DO THIS ONLY IF YOU KNOW WHAT YOU ARE DOING!"
  select choice in "Yes" "No"; do
    case $choice in
      Yes ) git filter-repo --force --partial --mailmap my-mailmap; rm my-mailmap; echo "run git fetch && git push --force-with-lease"; break;;
      No ) rm my-mailmap; exit;;
    esac
  done
}

change "$1" "$2" "$3"
