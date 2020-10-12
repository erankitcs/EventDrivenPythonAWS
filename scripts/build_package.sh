#!/usr/bin/env bash

# Change to the script directory
rm -rf lambda_package

mkdir lambda_package

cd lambda_package

unzip ../pythondist/numpy-1.19.2-cp36-cp36m-manylinux1_x86_64.whl

unzip ../pythondist/pandas-1.1.3-cp36-cp36m-manylinux1_x86_64.whl

unzip ../pythondist/pytz-2020.1-py2.py3-none-any.whl

rm -r  *.dist-info __pycache__

cp -r ../lambda_etl/* .