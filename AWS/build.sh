#!/bin/bash
#cd /Users/Jeremy/Synology/Emma/Mathematics/Primes/Primer/Primer
export LANG=en_US.US-ASCII

## MAC
export SRC_DIR=/Users/Jeremy/Projects/Primer/AWS/Primer/Source
export BUILD_DIR=/Users/Jeremy/Projects/Primer/AWS/Primer/Build
export BUILD_TOOL_DIR=/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/bin/

## AWS
#export SRC_DIR=./Primer/Source
#export BUILD_DIR=./Primer/Build
#export BUILD_TOOL_DIR=

##Compile NSString+FileIO.m
clang -x objective-c `gnustep-config --objc-flags` `gnustep-config --objc-libs` -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu99 -fmodules -Wnon-modular-include-in-framework-module -Werror=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -O0 -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -DDEBUG=1 -DOBJC_OLD_DISPATCH_PROTOTYPES=0 -fasm-blocks -fstrict-aliasing -fobjc-runtime=gnustep -fblocks -fobjc-arc -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -I$SRC_DIR -c $SRC_DIR/NSString+FileIO.m -o $BUILD_DIR/NSString+FileIO.o

##Compile NSArray+PrimeDesc.m
clang -x objective-c `gnustep-config --objc-flags` `gnustep-config --objc-libs` -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu99 -fmodules -Wnon-modular-include-in-framework-module -Werror=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -O0 -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -DDEBUG=1 -DOBJC_OLD_DISPATCH_PROTOTYPES=0 -fasm-blocks -fstrict-aliasing -fobjc-runtime=gnustep -fblocks -fobjc-arc -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -I$SRC_DIR -c $SRC_DIR/NSArray+PrimeDesc.m -o $BUILD_DIR/NSArray+PrimeDesc.o


#Compile main.mm
clang -x objective-c++ `gnustep-config --objc-flags` `gnustep-config --objc-libs` -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu++11 -stdlib=libstdc++ -fmodules -Wnon-modular-include-in-framework-module -Werror=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -O0 -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wno-non-virtual-dtor -Wno-overloaded-virtual -Wno-exit-time-destructors -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -Wno-c++11-extensions -DDEBUG=1 -DOBJC_OLD_DISPATCH_PROTOTYPES=0 -fasm-blocks -fstrict-aliasing -fobjc-runtime=gnustep -fblocks -fobjc-arc -Wprotocol -Wdeprecated-declarations -Winvalid-offsetof -g -fvisibility-inlines-hidden -Wno-sign-conversion -I$SRC_DIR -c $SRC_DIR/main.mm -o $BUILD_DIR/main.o


#Compile Primer.m
clang -x objective-c `gnustep-config --objc-flags` `gnustep-config --objc-libs` -fmessage-length=0 -fdiagnostics-show-note-include-stack -fmacro-backtrace-limit=0 -std=gnu99 -fmodules -Wnon-modular-include-in-framework-module -Werror=non-modular-include-in-framework-module -Wno-trigraphs -fpascal-strings -O0 -fno-common -Wno-missing-field-initializers -Wno-missing-prototypes -Werror=return-type -Wunreachable-code -Wno-implicit-atomic-properties -Werror=deprecated-objc-isa-usage -Werror=objc-root-class -Wno-arc-repeated-use-of-weak -Wduplicate-method-match -Wno-missing-braces -Wparentheses -Wswitch -Wunused-function -Wno-unused-label -Wno-unused-parameter -Wunused-variable -Wunused-value -Wempty-body -Wconditional-uninitialized -Wno-unknown-pragmas -Wno-shadow -Wno-four-char-constants -Wno-conversion -Wconstant-conversion -Wint-conversion -Wbool-conversion -Wenum-conversion -Wshorten-64-to-32 -Wpointer-sign -Wno-newline-eof -Wno-selector -Wno-strict-selector-match -Wundeclared-selector -Wno-deprecated-implementations -DDEBUG=1 -DOBJC_OLD_DISPATCH_PROTOTYPES=0 -fasm-blocks -fstrict-aliasing -fobjc-runtime=gnustep -fblocks -fobjc-arc -Wprotocol -Wdeprecated-declarations -g -Wno-sign-conversion -I$SRC_DIR -c $SRC_DIR/Primer.m -o $BUILD_DIR/Primer.o

#Link Primer
clang++ `gnustep-config --objc-flags` `gnustep-config --objc-libs` -L$BUILD_DIR -stdlib=libstdc++ -lgnustep-base -lobjc $BUILD_DIR/NSString+FileIO.o $BUILD_DIR/NSArray+PrimeDesc.o $BUILD_DIR/Primer.o $BUILD_DIR/main.o -o $BUILD_DIR/Primer