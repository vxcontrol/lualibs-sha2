[ `uname` = Linux ] && { export X=i686-w64-mingw32-; }
P=mingw32 C="-fPIC" L="-s -static-libgcc" D=sha2.dll A=sha2.a ./build.sh
