
TARGET := iphone:clang:latest:7.0

include /var/theos/makefiles/common.mk

TOOL_NAME = ClipBoardCLI

ClipBoardCLI_FILES = main.m Communicator.m
ClipBoardCLI_CFLAGS = -fobjc-arc
ClipBoardCLI_CODESIGN_FLAGS = -Sentitlements.plist
ClipBoardCLI_INSTALL_PATH = /usr/local/bin

include /var/theos/makefiles/tool.mk
