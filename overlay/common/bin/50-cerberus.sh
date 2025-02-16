#!/sbin/sh
#
# Functions for backuptool.sh
#

 export C=/tmp/backupdir
export S=/system
export V=16.0

 copy_file() {
  cp -dp "$1" "$2"
  # symlinks don't have a context
  if [ ! -L "$1" ]; then
    # it is assumed that every label starts with 'u:object_r' and has no white-spaces
    local context=`ls -Z "$1" | grep -o 'u:object_r:[^ ]*' | head -1`
    chcon "$context" "$2"
  fi
}

 backup_file() {
  if [ -e "$1" -o -L "$1" ]; then
    local F=`basename "$1"`
    local D=`dirname "$1"`
    # dont backup any apps that have odex files, they are useless
    if ( echo "$F" | grep -q "\.apk$" ) && [ -e `echo "$1" | sed -e 's/\.apk$/\.odex/'` ]; then
      echo "Skipping odexed apk $1";
    else
      mkdir -p "$C/$D"
      copy_file "$1" "$C/$D/$F"
    fi
  fi
}

 restore_file() {
  local FILE=`basename "$1"`
  local DIR=`dirname "$1"`
  if [ -e "$C/$DIR/$FILE" -o -L "$C/$DIR/$FILE" ]; then
    if [ ! -d "$DIR" ]; then
      mkdir -p "$DIR";
    fi
    copy_file "$C/$DIR/$FILE" "$1";
    if [ -n "$2" ]; then
      echo "Deleting obsolete file $2"
      rm "$2";
    fi
  fi
}