#!/bin/bash

if [ ! -e .ve ]; then
    virtualenv --no-site-packages .ve
fi

source .ve/bin/activate
export STATIC_DEPS=true
pip install -r requirements.txt
pip install -r dev_requirements.txt

#echo ----
#echo Force unzip of django-tastypie
#echo Looks like a bug in the package name makes our life hell
#echo ----
#pip uninstall -y django-tastypie
#easy_install -Z vendors/django-tastypie-0.9.11.tar.gz
