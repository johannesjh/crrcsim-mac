# HOW TO BUILD CRRCSIM 0.9.12 ON MAC OS 10.9
# ...compiling CRRCSim into an OSX application using MacPorts for dependencies


# CREDITS:
# Instructions heavily inspired by:
# http://blog.mywarwithentropy.com/2012/03/how-to-compile-crrcsim-v0912-for-mac.html


# PREREQUISITES
# install xcode
# install macports


# INSTALL LIBRARIES
sudo port install plib
sudo port install jpeg
sudo port install portaudio
sudo port install libsdl
sudo port install gmp
sudo port install cgal

# INSTALL COMPILER AND BUILD TOOLS
sudo port install wget
sudo port install gcc47
sudo port install dylibbundler


# DOWNLOAD CRRCSIM SOURCE CODE
# simply download the .tar.gz from source code archive from the crrcsim website, extract it to ~/repos/crrcsim
mkdir -p ~/repos/crrcsim
cd ~/repos/crrcsim
wget http://downloads.sourceforge.net/project/crrcsim/crrcsim/crrcsim-0.9.12/crrcsim-0.9.12.tar.gz
tar -zxvf crrcsim-0.9.12.tar.gz
rm crrcsim-0.9.12.tar.gz
mv crrcsim-0.9.12/* crrcsim-0.9.12/.* .
rmdir crrcsim-0.9.12


# APPLY A PATCH
# Apply a patch to crrcsim/src/mod_misc/filesystools.cpp.
# This is needed so CRRCSim can correctly find its resources inside the app bundle.
# The patch is inspired by the following blog post:
# http://blog.mywarwithentropy.com/2012/03/how-to-compile-crrcsim-v0912-for-mac.html
# ...but has been heavily modified to work on OSX Mavericks.
cd ~/repos/crrcsim
patch -p1 -R << 'EOF'
diff --git a/src/mod_misc/filesystools.cpp b/src/mod_misc/filesystools.cpp
index b20eb3a..d085eb7 100644
--- a/src/mod_misc/filesystools.cpp
+++ b/src/mod_misc/filesystools.cpp
@@ -40,9 +40,6 @@
 # include <stdlib.h>     // getenv()
 # include <sys/stat.h>   // mkdir
 # include <sys/types.h>  // mkdir
-# include <sys/param.h> // MAXPATHLEN
-# include <CoreFoundation/CoreFoundation.h> // CFBundleGetMainBundle()
-
 #endif

 #ifdef WIN32
@@ -187,49 +184,13 @@ void FileSysTools::getSearchPathList(std::vector<std::string>& pathlist, std::st
   #endif
   #if defined(__APPLE__) || defined(MACOSX)
   {
-    std::string s = "./crrcsim.app/Contents/Resources";
+    std::string s = "/Library/Application Support/" + appname;
     if (dirname != "")
     {
       s.append("/");
       s.append(dirname);
     }
     pathlist.push_back(s);
-
-    std::string s1 = "./Resources";
-    if (dirname != "")
-     {
-        s1.append("/");
-        s1.append(dirname);
-     }
-    pathlist.push_back(s1);
-
-    std::string s2 = "../Resources";
-    if (dirname != "")
-     {
-       s2.append("/");
-       s2.append(dirname);
-     }
-    pathlist.push_back(s2);
-
-    char bundledir[MAXPATHLEN];
-    CFBundleRef mainbundle = CFBundleGetMainBundle();
-    if (mainbundle != NULL) {
-      CFURLRef appurl = CFBundleCopyBundleURL(mainbundle);
-      CFStringRef cfpath = CFURLCopyFileSystemPath(appurl, kCFURLPOSIXPathStyle);
-      if (CFStringGetFileSystemRepresentation(cfpath, bundledir, MAXPATHLEN) == true) {
-        //printf("MacOS X Bundle path: %s\n", bundledir);
-      }
-      std::string s3 (bundledir);
-      s3.append("/Contents/Resources");
-      if (dirname != "")
-       {
-         s3.append("/");
-         s3.append(dirname);
-       }
-      pathlist.push_back(s3);
-      CFRelease(appurl);
-      CFRelease(cfpath);
-    }
   }
   #endif
   #if 0
EOF


# CONFIGURE
# Note: make sure to configure the build so it uses gcc instead of clang, because you will otherwise get "implicit instantiation of undefined template" errors, compare http://stackoverflow.com/questions/19719684/how-do-you-fix-implicit-instantiation-errors-when-compiling-mesos-on-os-x-10-9
# Note 2: from my experience, you can safely ignore the warnings about portaudio > 18 being unstable.
# Note 3: Compiling with CGAL support requires the GMP library and the "-lgmp" linker flag, see http://stackoverflow.com/questions/4083285/cgal-linker-error-symbol-not-found-gmpq-clear
cd ~/repos/crrcsim
CC=gcc-mp-4.7 CXX=g++-mp-4.7 ./configure CPPFLAGS="-I/opt/local/include -DAPIENTRY=" LDFLAGS="-L/opt/local/lib -lintl -lgmp -framework OpenGL -headerpad_max_install_names" --prefix=$HOME/crrcsim.app


# COMPILE
cd ~/repos/crrcsim
make


# INSTALL INTO HOME FOLDER
cd ~/repos/crrcsim
make install


# ASSEMBLE AN OSX APPLICATION BUNDLE
# Note: heavily inspired by http://blog.mywarwithentropy.com/2012/03/how-to-compile-crrcsim-v0912-for-mac.html
cd $HOME/crrcsim.app
mkdir Contents
cd Contents
mkdir Frameworks PlugIns Resources SharedFrameworks
mv ../bin MacOS
mv ../share/crrcsim/* Resources/
mv ../share Resources/
rmdir Resources/share/crrcsim/
mv Resources/share/doc/crrcsim/* Resources/share/doc/
rmdir Resources/share/doc/crrcsim/
curl http://sourceforge.net/p/crrcsim/code/ci/default/tree/macosx/crrcsim.icns?format=raw > Resources/crrcsim.icns
cat << 'EOF' > Info.plist
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple Computer//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>CFBundleDisplayName</key>
        <string>CRRC Simulator</string>
        <key>CFBundleName</key>
        <string>crrcsim</string>
        <key>CFBundlePackageType</key>
        <string>APPL</string>
        <key>CFBundleExecutable</key>
        <string>crrcsim</string>
        <key>CFBundleVersion</key>
        <string>0.9.12</string>
        <key>CFBundleShortVersionString</key>
        <string>0.9.12</string>
        <key>CFBundleDevelopmentRegion</key>
        <string>English</string>
        <key>CFBundleHelpBookFolder</key>
        <string>share/doc/</string>
        <key>CFAppleHelpAnchor</key>
        <string>index.html</string>
        <key>CFBundleIconFile</key>
        <string>crrcsim</string>
        <key>CFBundleIdentifier</key>
        <string>http://crrcsim.sourceforge.net</string>
        <key>CFBundleInfoDictionaryVersion</key>
        <string>6.0</string>
        <key>CFBundleSignature</key>
        <string>JORD</string>
        <key>NSPrincipalClass</key>
        <string>SDLApplication</string>
        <key>NSHumanReadableCopyright</key>
        <string>Copyright 2006 GNU General Public License</string>
        <key>crrcsim</key>
        <string>SDL Cocoa App</string>
</dict>
</plist>
EOF


# COPY DYNAMIC LIBRARIES INTO THE .APP BUNDLE
# Note: For info, instructions and tutorials, see:
# http://stackoverflow.com/questions/1596945/building-osx-app-bundle
# http://stackoverflow.com/questions/12516877/bundling-dylibs-headerpad-max-install-names-not-working

# Using dylibbundler:
cd $HOME
dylibbundler -od -b -i /usr/lib -i /System/ -d crrcsim.app/Contents/libs -p @executable_path/../libs/ -x crrcsim.app/Contents/MacOS/crrcsim


# OPTIONALLY, DELETE YOUR SETTINGS FILE
rm $HOME/Library/Preferences/crrcsim.xml


# TEST CRRCSIM
# Note: You could directly run the binary using `$HOME/crrcsim.app/Contents/MacOS/crrcsim`, but it is best to run the app by double-clicking on it in the OSX Finder, or by running:
open $HOME/crrcsim.app



# OPTIONALLY, CREATE A DMG DISK IMAGE
# For options how to create dmg images, see the following webpages:
# http://dmgcreator.sourceforge.net/
# http://wiki.octave.org/Create_a_MacOS_X_App_Bundle_Using_MacPorts#Create_an_Installer_DMG
# http://stackoverflow.com/questions/96882/how-do-i-create-a-nice-looking-dmg-for-mac-os-x-using-command-line-tools



# OPTIONALLY, INSTALL TO APPLICATIONS FOLDER
mv $HOME/crrcsim.app /Applications
