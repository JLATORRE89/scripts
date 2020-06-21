#!/usr/bin/python
# This script is used to install python modules that are needed for a package.
import sys
import subprocess
import os

cwd = os.getcwd()
os.chdir(cwd)

# Define module list.
modules = ['pandas',
            'xlsxwriter',
            'oauth2client',
            'gspread',
            'numpy']

for item in modules:
# Implement pip as a subprocess:
    subprocess.check_call([sys.executable, '-m', 'pip', 'install',
    item])

# Process output with an API in the subprocess module:
reqs = subprocess.check_output([sys.executable, '-m', 'pip',
'freeze'])
installed_packages = [r.decode().split('==')[0] for r in reqs.split()]
packageString = ''

for item in installed_packages:
    packageString += item + ',\n'

packageString = packageString[:-2]
outputFile = open("Installed_Packages.txt", "w")
# Write output to file.
outputFile.writelines(packageString)
