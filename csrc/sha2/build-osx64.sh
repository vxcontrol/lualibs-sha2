[ `uname` = Linux ] && { export X=x86_64-apple-darwin19-; export CC=clang; }
P=osx64 CC=clang C="-arch x86_64 -fPIC" L="-arch x86_64 -static -lm -install_name @rpath/libsha2.dylib" \
	D=libsha2.dylib A=libsha2.a ./build.sh
