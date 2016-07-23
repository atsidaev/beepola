@echo off
if "%1" == "" goto exitnoparams
svn copy svn://svn.grok.co.uk/var/svn/beepola/trunk svn://svn.grok.co.uk/var/svn/beepola/tags/%1 -m "Tagging %1"
goto endall
:exitnoparams
echo Usage: make_tag tagdir
:endall
