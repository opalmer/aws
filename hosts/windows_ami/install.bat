SET DOWNLOADS=C:\downloads
SET PYTHON_TARGETDIR=C:\python

msiexec /qb /i %DOWNLOADS%\7-zip.msi
del %DOWNLOADS%\7-zip.msi

SET PATH=%PATH%;C:\Program Files\7-zip;

:: Prepare setuptools, pip and virtualenv
7z x %DOWNLOADS%\setuptools-18.2.zip -o%DOWNLOADS%\
7z x %DOWNLOADS%\pip-7.1.2.tar.gz -o%DOWNLOADS%
7z x %DOWNLOADS%\dist\pip-7.1.2.tar -o%DOWNLOADS%
move %DOWNLOADS%\pip-7.1.2 %DOWNLOADS\pip
del %DOWNLOADS%\pip-7.1.2.tar.gz
7z x %DOWNLOADS%\virtualenv-13.1.2.tar.gz -o%DOWNLOADS%
7z x %DOWNLOADS%\dist\virtualenv-13.1.2.tar -o%DOWNLOADS%
move %DOWNLOADS%\virtualenv-13.1.2 %DOWNLOADS\virtualenv
del %DOWNLOADS%\virtualenv-13.1.2.tar.gz
rmdir /s /q %DOWNLOADS%\dist

:: Install CPython Interpreters
CALL :install_cpython python-2.6.6.amd64 cpython-2.6.6-64
CALL :install_cpython python-2.6.6 cpython-2.6.6-32
CALL :install_cpython python-2.7.10.amd64 cpython-2.7.10-64
CALL :install_cpython python-2.7.10 cpython-2.7.10-32
CALL :install_cpython python-3.2.5.amd64 cpython-3.2.5-64
CALL :install_cpython python-3.2.5 cpython-3.2.5-32
CALL :install_cpython python-3.3.5.amd64 cpython-3.3.5-64
CALL :install_cpython python-3.3.5 cpython-3.3.5-32
CALL :install_cpython python-3.4.3.amd64 cpython-3.4.3-64
CALL :install_cpython python-3.4.3 cpython-3.4.3-32

:: Install PyPy Interpreters
CALL :install_pypy pypy-2.6.0-win32 pypy3-2.4.0-32
CALL :install_pypy pypy3-2.4.0-win32 pypy3-2.4.0-32

:: Extract the ISO files
CALL :extract_iso VS2008ExpressENUX1397868
:: TODO: call install program
CALL :extract_iso VS2010Express1
:: TODO: call install program
CALL :extract_iso GRMSDK_EN_DVD
:: TODO: call install program

dism /Online /Enable-Feature /Featurename:NetFX3 /All


EXIT /B %ERRORLEVEL%
GOTO:EOF

::
:: Functions
::

:install_cpython
:: Install MSI
msiexec /qb /i %DOWNLOADS%\%~1.msi ALLUSERS=1 TARGETDIR=%PYTHON_TARGETDIR%\%~2
del %DOWNLOADS%\%~1.msi

:: Install setuptools, pip and virtualenv
cd %DOWNLOADS%\setuptools\
%PYTHON_TARGETDIR%\%~2\python.exe setup.py install
cd %DOWNLOADS%\pip\
%PYTHON_TARGETDIR%\%~2\python.exe setup.py install
cd %DOWNLOADS%\virtualenv\
%PYTHON_TARGETDIR%\%~2\python.exe setup.py install

:: De-associate file extensions
assoc .py=
assoc .pyc=
assoc .pyo=
assoc .pyw=
GOTO:EOF

:install_pypy
:: Extract
7z x %DOWNLOADS%\%~1.zip -o%PYTHON_TARGETDIR%
move %PYTHON_TARGETDIR%\%~1 %PYTHON_TARGETDIR%\%~2
del %DOWNLOADS%\%~1.zip

:: Install setuptools, pip and virtualenv
cd %DOWNLOADS%\setuptools\
%PYTHON_TARGETDIR%\%~2\pypy.exe setup.py install
cd %DOWNLOADS%\pip\
%PYTHON_TARGETDIR%\%~2\pypy.exe setup.py install
cd %DOWNLOADS%\virtualenv\
%PYTHON_TARGETDIR%\%~2\pypy.exe setup.py install
GOTO:EOF

:extract_iso
7x -o %DOWNLOADS%\%~1.iso -o %DOWNLOADS\%~1
del %DOWNLOADS%\%~1.iso

ENDLOCAL
GOTO:EOF
