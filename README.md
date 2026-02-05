# ag_privapp

This addon allows you to include various prebuild apk's and in some cases also sign them with platform keys.

## Dependencies:

1) bass-toolkit - https://github.com/Bliss-Bass/bass-os
2) Android SDK 34 - https://developer.android.com/tools/releases/platform-tools (Saved in ~/Android/Sdk )

Make sure that the apksigner binary is found at ~/Android/Sdk/build-tools/34.0.0-rc3/apksigner

## How to use

Place your apk's in the following folders:

 - prebuilts/apps - This is for normal apps that do not require elevated permissions
 - prebuilts/priv-apps - This is for apps that do require elevated permissions
 - prebuilts/priv-api-apps - This is for apps that do require elevated permissions and include api's
 - prebuilts/prod-priv-api-apps - This is for apps that are for the product partition, require elevated permissions and include api's
 - prebuilts/prod-plat-priv-api-apps - This is for apps that are for the product partition, require elevated permissions, include api's and are signed with platform keys
 - prebuilts/unsigned-priv-api-apps - This is for apps that do require elevated permissions, include api's, and require a platform signature
 - prebuilts/user_apps - This is for apps that you want installed on first boot, but want to allow users to uninstall

 After you have placed the apk's in the corresponding folders, you will need to run the update.sh from this folder with one of the following arguments, or blank to force it to ask:

 1: ABI:x86_64 & ABI2:x86
 2: ABI:arm64-v8a & ABI2:armeabi-v7
 3: ABI:x86
 4: ABI:armeabi-v7a

 Example:

    ```
    bash update.sh 1
    ```

You can now cd to your project folder and create your build. Thank you for using

## But wait, what did it do?

##### Short answer:
Everything needed to include your apps.

##### Long answer:
The `update.sh` script is the main workhorse. Here's a breakdown of what it does:
- It generates `Android.mk` and `apps.mk` files. These files are used by the Android build system to include your apps in the final image.
- It iterates through the `prebuilts` folders and, based on the folder, generates the appropriate makefile entries for each app. It also extracts any ABI-specific libraries from the APKs.
- For apps in the `unsigned-priv-api-apps` folder, it signs them using the platform keys found in `../../vendor/bass/configs/signing/`.

Next, `generate_perms.sh` is called by `update.sh`. This script does the following:
- It uses `aapt` to extract permissions from the APKs in the `bin` folder (where `update.sh` copied them).
- It generates three XML files:
    - `permissions/ag-priv-app-permissions.xml`: Contains permissions for privileged apps.
    - `default-permissions/ag-priv-default-permissions.xml`: Contains default permissions for apps.
    - `default-whitelist/whitelist-app.ag-priv.xml`: Whitelists apps for power-saving mode.

The `ag_privapp.mk` file is the entry point for the build system. It includes the generated `apps.mk` file and also inherits `init-permissions.mk`.

The `init-permissions.mk` file copies `preperms.rc` and `preperms.sh` to the product partition of the system image. These two files are responsible for installing user-facing apps on first boot:
- `preperms.rc`: This is an Android init script that starts the `preperms` service when the system has finished booting.
- `preperms.sh`: This script is executed by the `preperms` service. It installs any APKs located in `/system/etc/user_app/`. It also includes a placeholder function `set_custom_package_perms` that you can customize for your own needs.

The Bass Toolkit already has all the parts added to look for those created files, and inherit them and the ag_privapp.mk. So when you compile the project, all your apps will be included and all their permissions along with it.
