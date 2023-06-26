#!/bin/sh
df -h
# LLaMa.cpp for Python repo
git clone --depth 1 https://github.com/abetlen/llama-cpp-python
# But using a fork of LLaMa.cpp that supports HIP BLAS
cd llama-cpp-python/vendor
rmdir llama.cpp
git clone https://github.com/SlyEcho/llama.cpp
cd llama.cpp
git checkout hipblas
# Create the dynamic lib we need
LLAMA_HIPBLAS=1 make -j4 libllama.so
# Also the binaries
LLAMA_HIPBLAS=1 make -j4
mkdir ../../dist/
zip -9 ../../dist/llama_cpp.zip embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot convert*.py
# Now create the wheels
cd ../..
/opt/python/cp39-cp39/bin/pip3.9 install scikit-build
/opt/python/cp39-cp39/bin/python setup.py bdist_wheel
ls -la dist/*.whl
/opt/python/cp37-cp37m/bin/pip3.7 install scikit-build
/opt/python/cp37-cp37m/bin/python setup.py bdist_wheel
ls -la dist/*.whl
/opt/python/cp38-cp38/bin/pip3.8 install scikit-build
/opt/python/cp38-cp38/bin/python setup.py bdist_wheel
ls -la dist/*.whl
/opt/python/cp310-cp310/bin/pip3.10 install scikit-build
/opt/python/cp310-cp310/bin/python setup.py bdist_wheel
ls -la dist/*.whl
df -h
