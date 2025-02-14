#!/bin/bash

## current dir
DIRSCRIPT=$(cd $(dirname $0) && pwd)
DEST_HELPER_DIR='.helpers'
DEST_DOTFILES_DIR='.dotfiles'
FILLDESTDIR="/opt/$DEST_HELPER_DIR";

#create .helpers dir in user bash_profile
if [ ! -d ~/$FILLDESTDIR ]; then
    mkdir $FILLDESTDIR;
    echo $FILLDESTDIR "create dir";
else
    echo $FILLDESTDIR "found dir";
fi

chmod -R 777 $FILLDESTDIR;

if [ ! -L ~/$DEST_HELPER_DIR ]; then
    ln -s $FILLDESTDIR ~/$DEST_HELPER_DIR;
    echo ~/$DEST_HELPER_DIR "create link";
else
    echo ~/$DEST_HELPER_DIR "found link";
fi


#remotes
# REMOTE_BUNDLE_DIR='https://raw.githubusercontent.com/SCaeR42/bash-helpers/master'
# REMOTE_DIR_DIST=$REMOTE_BUNDLE_DIR/'.helpers'
FILE_BUNDLE='bash_helpers_bundle.sh'
FILE_LOCAL='local_aliases.sh'

VARIANT_ADD='FULL'
ADD_DOTFILES=false

. $DIRSCRIPT/helpers/000-main/_colors.sh
. $DIRSCRIPT/helpers/000-main/_functions.sh

while [ -n "$1" ]
do
case "$1" in
    -lite | --lite)
         VARIANT_ADD='LITE'
         shift
         ;;
    -dotfiles | --dotfiles)
         ADD_DOTFILES=true
         shift
         ;;
    *)
        echo "$1 не опция"
        break
        ;;
esac
done


# #add dotfiles
if [ "$ADD_DOTFILES" == true ]; then
    if [ ! -d ~/$DEST_DOTFILES_DIR ]; then
        cp -r $DIRSCRIPT/dotfiles  ~/$DEST_DOTFILES_DIR
    fi

    echo  'dir ' $DEST_DOTFILES_DIR

    if [ -d ~/$DEST_DOTFILES_DIR ]; then

        # add dotfiles
        for script in ~/$DEST_DOTFILES_DIR/.* ; do
        	if [ -f $script ] ; then
        		scriptName=$(basename $script)
        		ln -s --backup='t' ~/$DEST_DOTFILES_DIR/$scriptName ~/$scriptName
        		_success "create simlink: $scriptName";
        	fi
        done

    fi
fi


chmod 777 ./build.sh;
./build.sh;

if [ "$VARIANT_ADD" == "LITE" ]; then

echo 'source ' $DIRSCRIPT/$DEST_HELPER_DIR/$FILE_BUNDLE
echo 'source ' $DIRSCRIPT/$DEST_HELPER_DIR/$FILE_LOCAL

rm -fr ../bash-helpers

exit 0;
fi

#create .helpers dir in user bash_profile
if [ ! -d ~/$DEST_HELPER_DIR ]; then
    mkdir ~/$DEST_HELPER_DIR;
    echo ~/$DEST_HELPER_DIR "create dir";
else
    echo ~/$DEST_HELPER_DIR "found dir";
fi

# if [ ! -d $DIRSCRIPT/$DEST_HELPER_DIR ]; then
#
#     #copy files
#     wget $REMOTE_DIR_DIST/$FILE_BUNDLE -O ~/$DEST_HELPER_DIR/000-$FILE_BUNDLE
#
#     #get file if not exist
#     if [ ! -f ~/$DEST_HELPER_DIR/$FILE_LOCAL ]; then
#         wget $REMOTE_DIR_DIST/$FILE_LOCAL -O ~/$DEST_HELPER_DIR/$FILE_LOCAL
#     fi
#
#     #remove init file
# #     rm -fr $DIRSCRIPT/init.sh
#
# else

cp $DIRSCRIPT/$DEST_HELPER_DIR/$FILE_BUNDLE  ~/$DEST_HELPER_DIR/000-$FILE_BUNDLE
cp -r $DIRSCRIPT/$DEST_HELPER_DIR/cron_helpers  ~/$DEST_HELPER_DIR/

#copy file if not exist
if [ ! -f ~/$DEST_HELPER_DIR/$FILE_LOCAL ]; then
    cp $DIRSCRIPT/$DEST_HELPER_DIR/$FILE_LOCAL  ~/$DEST_HELPER_DIR/$FILE_LOCAL
fi
# fi

# Копируем все файлы, кроме local_aliases.sh
for file in $DIRSCRIPT/$DEST_HELPER_DIR/*; do
  if [[ "$(basename "$file")" != "local_aliases.sh" && "$(basename "$file")" != "bash_helpers_bundle.sh" ]]; then
      cp "$file" ~/$DEST_HELPER_DIR
    fi
done

#create bash_profile in not exist
if [ ! -f ~/.bash_profile ]; then
	touch  ~/.bash_profile;
cat >> ~/.bash_profile << \EOF
# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs
PATH=$PATH:$HOME/bin
export PATH
EOF
	echo ".bash_profile file create";
fi

#enabled files on .bash_profile
if [ -f ~/.bash_profile ]; then
if grep -Eq '##### BASH HELPERS #####' ~/.bash_profile; then
echo ".helpers found in .bash_profile file";
else
cat >> ~/.bash_profile << \EOF
##### BASH HELPERS #####
bhlp() {
  # If not running interactively, don't do anything
  case $- in
      *i*) ;;
        *) return;;
  esac

  for script in ~/.helpers/*.sh ; do
      # Пропустить файл, если его имя содержит "cron_"
      if [[ "$script" == *cron_* ]]; then
          continue
      fi

      if [ -f "$script" ]; then
          . "$script"
      fi
  done
}

alias ??='bhlp'
??

EOF
echo ".bash_helpers added to .bash_profile file";
fi
fi

## add dotfiles
# for script in $DIRSCRIPT/dotfiles/.* ; do
# 	if [ -f $script ] ; then
# 		scriptName=$(basename $script)
# 		if [ -h $scriptName ] ; then
# 			rm ~/$scriptName
# 			_info "${_Cyan}simlink: ${_Yellow}$scriptName${_Cyan} deleted";
# 		fi
# 		if [ -f $scriptName ] ; then
# 			mv ~/$scriptName ~/old_$scriptName
# 			_info "${_Cyan}file: ${_Yellow}$scriptName${_Cyan} moved";
# 		fi
# 		ln -s $DIRSCRIPT/dotfiles/$scriptName ~/$scriptName
# 		_info "${_Cyan}create simlink: ${_Yellow}$scriptName";
# 	fi
# done


echo "Deleted tep files...";
rm -fr ../bash-helpers

cd ~

echo "Reload...";
#applying changes
#source ~/.bash_profile
exec ${SHELL} -l
