@ECHO OFF
:START

REM Help the user if they're not in the correct directory.
IF NOT EXIST LAUNCHBX.EXE ECHO.
IF NOT EXIST LAUNCHBX.EXE ECHO You have run LaunchBox from outside of the LaunchBox directory.
IF NOT EXIST LAUNCHBX.EXE ECHO.
IF NOT EXIST LAUNCHBX.EXE ECHO Please make sure that you change into the LaunchBox directory using the CD
IF NOT EXIST LAUNCHBX.EXE ECHO command before running LAUNCH.BAT.
IF NOT EXIST LAUNCHBX.EXE ECHO.
IF NOT EXIST LAUNCHBX.EXE ECHO For example:
IF NOT EXIST LAUNCHBX.EXE ECHO.
IF NOT EXIST LAUNCHBX.EXE ECHO C:
IF NOT EXIST LAUNCHBX.EXE ECHO CD \LAUNCH
IF NOT EXIST LAUNCHBX.EXE ECHO LAUNCH.BAT
IF NOT EXIST LAUNCHBX.EXE ECHO.
IF NOT EXIST LAUNCHBX.EXE GOTO FINAL

REM Start the LaunchBox application
LAUNCHBX.EXE /FROMBATCH

REM If the application was exited or errored, then stop and end the batch
IF ERRORLEVEL 1 GOTO END

REM Execute the program defined by the application 
CALL RUN.BAT

REM Open LaunchBox once again after the program has exited
GOTO START

:END

REM Clean up temporary file
IF EXIST RUN.BAT DEL RUN.BAT

:FINAL

