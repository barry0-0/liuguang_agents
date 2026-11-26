#!/bin/zsh
set -euo pipefail

project_directory="${0:A:h:h}"
cd "$project_directory"
# The release workflow sets APP_VERSION from the tag and APP_BUILD_NUMBER from its run. A local build shows the commit
# it was built from, such as 1.1.0-3-gf45492c, read before this script generates any files. Its build number 0 is
# older than every release, so Check for updates still offers the latest one, but automatic checks are off by default:
# a development build is not interrupted by update offers or counted as an install of a release.
if [[ -n "${APP_VERSION:-}" ]]; then
    app_version="$APP_VERSION"
    build_number="${APP_BUILD_NUMBER:?APP_BUILD_NUMBER must be set with APP_VERSION}"
    checks_for_updates_automatically=true
else
    app_version="${APP_VERSION:-1.0.0}"
    build_number="${APP_BUILD_NUMBER:-0}"
    checks_for_updates_automatically=false
fi
python3 Scripts/Localization/compile_catalog.py
# Swift Build, the default from Swift 6.4, makes resource bundle accessors that look in the app's Contents/Resources.
# The native build system, the default on the release runner's older Swift, makes ones that look only beside the .app
# and in the build folder of the machine that built it, so Ghostty's package, which finds its resources through one,
# stopped v1.2.0 on every other Mac as soon as Ghostty was chosen.
release_build=(swift build -c debug --build-system native -Xswiftc -Xfrontend -Xswiftc -disable-round-trip-debug-types)
build_directory="$("${release_build[@]}" --show-bin-path)"
# Recreate this generated bundle: incremental SwiftPM builds can retain a removed language directory.
rm -rf "$build_directory/Liuguang_Liuguang.bundle"
"${release_build[@]}"

app_directory="${1:-$project_directory/dist/流光.app}"
if [[ "$app_directory" != *.app ]]; then
    print -u2 "The app bundle path must end in .app: $app_directory"
    exit 1
fi
# Once the app has been opened, macOS App Management refuses writes inside its bundle ("Operation not permitted"),
# but still allows removing the bundle. Each build assembles a fresh one.
rm -rf "$app_directory"
mkdir -p "$app_directory/Contents/MacOS" "$app_directory/Contents/Resources" "$app_directory/Contents/Frameworks"
cp "$build_directory/Liuguang" "$app_directory/Contents/MacOS/流光"
install_name_tool -add_rpath @executable_path/../Frameworks "$app_directory/Contents/MacOS/流光"
ditto "$build_directory/Sparkle.framework" "$app_directory/Contents/Frameworks/Sparkle.framework"
localization_resources="$build_directory/Liuguang_Liuguang.bundle"
ditto "$localization_resources" "$app_directory/Contents/Resources/Liuguang_Liuguang.bundle"
# SwiftUI's standard controls look in Bundle.main; AppKit strings use the SwiftPM resource bundle.
# SwiftPM's native build system lays the bundle out flat; its default swiftbuild system uses Contents/Resources.
localization_directories=("$localization_resources"/*.lproj(N) "$localization_resources"/Contents/Resources/*.lproj(N))
if (( ${#localization_directories} == 0 )); then
    print -u2 "No localizations were found in $localization_resources"
    exit 1
fi
localization_identifiers=()
for localization_directory in "${localization_directories[@]}"; do
    ditto "$localization_directory" "$app_directory/Contents/Resources/${localization_directory:t}"
    localization_identifiers+=("${${localization_directory:t}%.lproj}")
done
# Translations of Info.plist's strings, such as the microphone prompt; the String Catalog only makes Localizable.strings.
for info_plist_translation in "$project_directory"/Localization/InfoPlist/*.lproj/InfoPlist.strings(N); do
    ditto "$info_plist_translation" "$app_directory/Contents/Resources/${info_plist_translation:h:t}/InfoPlist.strings"
done
swiftterm_resources="$build_directory/SwiftTerm_SwiftTerm.bundle"
if [[ -d "$swiftterm_resources" ]]; then
    ditto "$swiftterm_resources" "$app_directory/Contents/Resources/SwiftTerm_SwiftTerm.bundle"
fi
cp -f "$project_directory/.build/checkouts/SwiftTerm/LICENSE" "$app_directory/Contents/Resources/SwiftTerm-LICENSE.txt"
# Ghostty's terminal reads its shell integration and terminfo from this bundle, and stops the app if it is missing.
ghostty_resources="$build_directory/GhosttyKit_GhosttyTerminal.bundle"
cp -f "$project_directory/Branding/ThirdParty/Octicons/LICENSE" "$app_directory/Contents/Resources/Octicons-LICENSE.txt"
# The font itself ships in the resource bundle above; keep its license with the other third-party licenses.
cp -f "$project_directory/Sources/Liuguang/Resources/Fonts/SymbolsNerdFontMono-LICENSE.txt" "$app_directory/Contents/Resources/SymbolsNerdFontMono-LICENSE.txt"
# Assets.car carries the light, dark and tinted icons for macOS 26; older macOS falls back to AppIcon.icns.
cp -f "$project_directory/Branding/AppIcon.icns" "$app_directory/Contents/Resources/AppIcon.icns"
tmux_runtime_directory="$("$project_directory/Scripts/Tmux/build-runtime.sh")"
ditto "$tmux_runtime_directory" "$app_directory/Contents/Resources/Tmux"
cat >"$app_directory/Contents/Info.plist" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0"><dict>
    <key>CFBundleName</key><string>流光</string>
    <key>CFBundleDisplayName</key><string>流光</string>
    <key>CFBundleIdentifier</key><string>dev.barry.liuguang</string>
    <key>CFBundleExecutable</key><string>流光</string>
    <key>CFBundleIconFile</key><string>AppIcon</string>
    <key>CFBundleIconName</key><string>AppIcon</string>
    <key>CFBundlePackageType</key><string>APPL</string>
    <key>CFBundleDevelopmentRegion</key><string>zh-Hans</string>
    <key>CFBundleShortVersionString</key><string>VERSION_PLACEHOLDER</string>
    <key>CFBundleVersion</key><string>BUILD_NUMBER_PLACEHOLDER</string>
    <key>LSMinimumSystemVersion</key><string>14.0</string>
    <key>NSHighResolutionCapable</key><true/>
    <key>NSMicrophoneUsageDescription</key><string>流光中运行的程序想要使用你的麦克风。</string>
    <key>NSDesktopFolderUsageDescription</key><string>流光需要访问你选择的桌面文件，以便在终端中预览和发送附件。</string>
    <key>NSDocumentsFolderUsageDescription</key><string>流光需要访问你选择的文稿文件，以便在终端中预览和发送附件。</string>
    <key>NSDownloadsFolderUsageDescription</key><string>流光需要访问你选择的下载文件，以便在终端中预览和发送附件。</string>
    <key>SUVerifyUpdateBeforeExtraction</key><true/>
</dict></plist>
PLIST
plutil -insert CFBundleLocalizations -json "$(python3 -c 'import json, sys; print(json.dumps(sys.argv[1:]))' "${localization_identifiers[@]}")" "$app_directory/Contents/Info.plist"
plutil -replace CFBundleVersion -string "$build_number" "$app_directory/Contents/Info.plist"
plutil -replace CFBundleShortVersionString -string "$app_version" "$app_directory/Contents/Info.plist"
plutil -replace SUEnableAutomaticChecks -bool "$checks_for_updates_automatically" "$app_directory/Contents/Info.plist"
source_revision="local"
plutil -insert LiuguangSourceRevision -string "$source_revision" "$app_directory/Contents/Info.plist"
plutil -insert CFBundleAuthor -string "barry" "$app_directory/Contents/Info.plist"
codesign_identity="${CODE_SIGN_IDENTITY:--}"
if [[ "$codesign_identity" == "-" ]]; then
    codesign --force --sign "$codesign_identity" "$app_directory/Contents/Resources/Tmux/bin/tmux"
    codesign --force --deep --sign "$codesign_identity" "$app_directory"
else
    codesign --force --options runtime --timestamp --sign "$codesign_identity" "$app_directory/Contents/Resources/Tmux/bin/tmux"
    codesign --force --deep --options runtime --timestamp --sign "$codesign_identity" "$app_directory"
    # Without --deep, so the entitlements go to the app alone and not to Sparkle's helpers. macOS asks the app's
    # permission for what its terminals run, so a CLI's voice input needs the app's audio-input entitlement.
    codesign --force --options runtime --timestamp --entitlements "$project_directory/Scripts/Liuguang.entitlements" --sign "$codesign_identity" "$app_directory"
fi
python3 "$project_directory/Scripts/Tmux/verify-runtime.py" "$app_directory/Contents/Resources/Tmux"
echo "$app_directory"
