#!/bin/sh
# A lot of df because we had problems with GitHub disk space.
df -h
# My fork is slightly better
git clone --depth 1 https://github.com/set-soft/GPTQ-for-LLaMa-ROCm.git
cd GPTQ-for-LLaMa-ROCm
/opt/python/cp39-cp39/bin/pip3.9 install torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
df -h
/opt/python/cp39-cp39/bin/python setup_rocm.py bdist_wheel
rm -R /opt/python/cp39-cp39/lib/python3.9/site-packages/torch
df -h
/opt/python/cp37-cp37m/bin/pip3.7 install torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
df -h
/opt/python/cp37-cp37m/bin/python setup_rocm.py bdist_wheel
rm -R /opt/python/cp37-cp37m/lib/python3.7/site-packages/torch
df -h
/opt/python/cp38-cp38/bin/pip3.8 install torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
df -h
/opt/python/cp38-cp38/bin/python setup_rocm.py bdist_wheel
rm -R /opt/python/cp38-cp38/lib/python3.8/site-packages/torch
df -h
/opt/python/cp310-cp310/bin/pip3.10 install torch==1.13.1+rocm5.2 --extra-index-url https://download.pytorch.org/whl/rocm5.2
df -h
/opt/python/cp310-cp310/bin/python setup_rocm.py bdist_wheel
rm -R /opt/python/cp310-cp310/lib/python3.10/site-packages/torch
df -h
