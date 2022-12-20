[ "$CC" ] || CC=gcc
mkdir -p ../../bin/$P
${X}${CC} -c -O2 $C sha2.c -I. -DSHA2_USE_INTTYPES_H -DBYTE_ORDER -DLITTLE_ENDIAN
${X}${CC} *.o -shared -o ../../bin/$P/$D $L
rm -f      ../../bin/$P/$A
${X}ar rcs ../../bin/$P/$A *.o
rm *.o
