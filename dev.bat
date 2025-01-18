@echo off

set OUT_DIR=build\dev

if not exist %OUT_DIR% mkdir %OUT_DIR%

odin run src --debug -out:%OUT_DIR%\life-keeper.exe
