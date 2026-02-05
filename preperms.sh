#!/system/bin/sh

first_run=$(getprop persist.bass.first_run)

set_custom_package_perms()
{
	# Set up custom package permissions

	current_user="0"

	# YourPackageName
	exists_yourpackage=$(pm list packages com.example.yourpackagename | grep -c com.example.yourpackagename)
	if [ $exists_yourpackage -eq 1 ]; then
		pm set-home-activity "com.example.yourpackagename/.ui.MainActivity"
		am start -a android.intent.action.MAIN -c android.intent.category.HOME
	fi

}

POST_INST=/data/vendor/post_inst_complete
USER_APPS=/system/etc/user_app/*
BUILD_DATETIME=$(getprop ro.build.date.utc)
POST_INST_NUM=$(cat $POST_INST)

set_custom_package_perms

if [ ! "$BUILD_DATETIME" == "$POST_INST_NUM" ]; then
	# Bliss user_apps
	for apk in $USER_APPS
	do		
		pm install $apk
	done
	rm "$POST_INST"
	touch "$POST_INST"
	echo $BUILD_DATETIME > "$POST_INST"
fi


