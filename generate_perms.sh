#!/bin/bash
# Generate AOSP Premisisons.xml from folder of .apk files

# Change these if using outside this project
APK_FOLDER="bin"
PERMS_LOCATION="permissions"
PERMS_FILENAME="ag-priv-app-permissions.xml"
DEFAULT_PERMS_LOCATION="default-permissions"
DEFAULT_PERMS_FILENAME="ag-priv-default-permissions.xml"
DEFAULT_WHITELIST_LOCATION="default-whitelist"
DEFAULT_WHITELIST_FILENAME="whitelist-app.ag-priv.xml"

# NO MORE EDITING BELOW HERE
PARSED_PERMS_PATH="$PERMS_LOCATION/$PERMS_FILENAME"
PARSED_DEFAULT_PERMS_PATH="$DEFAULT_PERMS_LOCATION/$DEFAULT_PERMS_FILENAME"
PARSED_WHITELIST_PATH="$DEFAULT_WHITELIST_LOCATION/$DEFAULT_WHITELIST_FILENAME"
FILES="$APK_FOLDER/*.apk"

addPerms() {
perms_list=""
cat >> $PARSED_PERMS_PATH <<EOF
	<privapp-permissions package="$2">
EOF
for i in "$@" ; do
	perms_list+="$i "
done
echo ""
#~ echo -e "Prems List: $perms_list"
#~ echo ""
for i in $perms_list ; do
if [ "$i" == "uses-permission:" ]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"package:"* ]]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"name="* ]]; then
  if [[ "$i" == *"android.permission"* ]] || [[ "$i" == *"com.google.android"* ]]; then
    temp_str=$(echo "$i" | sed -e "s/'/\"/g")
    cat >> $PARSED_PERMS_PATH <<EOF
		<permission $temp_str/>
EOF
  fi
fi
done
cat >> $PARSED_PERMS_PATH <<EOF
    </privapp-permissions>

EOF
}

addDefaultPerms() {

  # <?xml version="1.0" encoding="utf-8" standalone="yes"?>
  # <exceptions>
  #     <exception package="org.package.name">
  #         <permission name="android.permission.READ_CONTACTS" fixed="true" />
  #         <permission name="android.permission.WRITE_CONTACTS" fixed="true" />
  #     </exception>
  # </exceptions>

perms_list=""
cat >> $PARSED_DEFAULT_PERMS_PATH <<EOF
	<exception package="$2">
EOF
for i in "$@" ; do
	perms_list+="$i "
done
echo ""
#~ echo -e "Prems List: $perms_list"
#~ echo ""
for i in $perms_list ; do
if [ "$i" == "uses-permission:" ]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"package:"* ]]; then
	# echo -e "skipping meaningless line"
  continue
elif [[ "$i" == *"name="* ]]; then
if [[ "$i" == *"android.permission"* ]] || [[ "$i" == *"com.google.android"* ]]; then
temp_str=$(echo "$i" | sed -e "s/'/\"/g")
cat >> $PARSED_DEFAULT_PERMS_PATH <<EOF
		<permission $temp_str fixed="true"/>
EOF
fi
fi
done
cat >> $PARSED_DEFAULT_PERMS_PATH <<EOF
    </exception>

EOF
}

addWhitelistPerms() {

  # <?xml version="1.0" encoding="utf-8"?>
  # <config>
  #     <allow-in-power-save package="app.org.name" />
  # </config>

echo -e ""
echo -e "Adding to whitelist: $@"
echo -e ""
cat >> $PARSED_WHITELIST_PATH <<EOF
	<allow-in-power-save package="$1" />
EOF

}

# privapp

echo -e "${LT_BLUE}# Generating Private App Permissions XML ${NC}"
rm -Rf $PARSED_PERMS_PATH
mkdir -p permissions
cat > $PARSED_PERMS_PATH <<EOF
<permissions>

EOF

for f in $FILES
do
  echo -e ""
  echo "Processing $f file..."
  cmd_list=""
  argumentqa=$(aapt d permissions "$f")
  echo ""
  echo -e "Permissions for $argumentqa"
  echo ""
  for line in $argumentqa; do 
    read -a array <<< $line
    echo ${array[index]}  
    cmd_list+="${array[index]} "
  done
  #~ echo -e "CMD_LIST: $cmd_list"
  addPerms $cmd_list
done

cat >> $PARSED_PERMS_PATH <<EOF
</permissions>

EOF

# default perms

echo -e "${LT_BLUE}# Generating Private App Permissions XML ${NC}"
rm -Rf $PARSED_DEFAULT_PERMS_PATH
mkdir -p default-permissions
cat > $PARSED_DEFAULT_PERMS_PATH <<EOF
<?xml version="1.0" encoding="utf-8" standalone="yes"?>
<exceptions>

EOF

for f in $FILES
do
  echo -e ""
  echo "Processing $f file..."
  cmd_list=""
  argumentqa=$(aapt d permissions "$f")
  echo ""
  echo -e "Permissions for $argumentqa"
  echo ""
  for line in $argumentqa; do 
    read -a array <<< $line
    echo ${array[index]}  
    cmd_list+="${array[index]} "
  done
  #~ echo -e "CMD_LIST: $cmd_list"
  addDefaultPerms $cmd_list
done

cat >> $PARSED_DEFAULT_PERMS_PATH <<EOF
</exceptions>

EOF

# whitelist perms

echo -e "${LT_BLUE}# Generating whitelist XML ${NC}"
rm -Rf $PARSED_WHITELIST_PATH
mkdir -p default-whitelist
cat > $PARSED_WHITELIST_PATH <<EOF
<?xml version="1.0" encoding="utf-8"?>
<config>

EOF

for f in $FILES
do
  echo -e ""
  echo "Processing $f file..."
  cmd_list=""
  argumentqa=$(aapt d permissions "$f")
  # we only need the 2nd string in this query for package name
  argumentqa=$(echo $argumentqa | cut -d' ' -f2)
  echo ""
  echo -e "Whitelist for $argumentqa"
  echo ""
  for line in $argumentqa; do 
    read -a array <<< $line
    cmd_list+="${array[index]} "
  done
  addWhitelistPerms $cmd_list
done

cat >> $PARSED_WHITELIST_PATH <<EOF

</config>

EOF

echo ""
echo -e "All Set, permissions xml generated"
