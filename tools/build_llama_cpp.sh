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
# Disable native optimizations
sed -i -e 's/x86_64 i686/if_disabled/' Makefile
# First pass create a very generic binary
# Create the dynamic lib we need
LLAMA_HIPBLAS=1 make -j4 libllama.so
# Also the binaries
LLAMA_HIPBLAS=1 make -j4
mkdir ../../dist/
mv libllama.so libllama_generic.so
zip -9 ../../dist/llama_cpp_generic.zip embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot convert*.py libllama_generic.so
make clean
# 2nd pass create AVX optimized binary
sed -i -e 's/OPT = .*/OPT = -O3 -mfma -mf16c -mavx/' Makefile
LLAMA_HIPBLAS=1 make -j4 libllama.so
LLAMA_HIPBLAS=1 make -j4
mv libllama.so libllama_avx.so
zip -9 ../../dist/llama_cpp_avx.zip embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot convert*.py libllama_avx.so
make clean
# 3rd pass create an SSSE3 optimized binary
sed -i -e 's/OPT = .*/OPT = -O3 -mssse3/' Makefile
LLAMA_HIPBLAS=1 make -j4 libllama.so
LLAMA_HIPBLAS=1 make -j4
cp libllama.so libllama_ssse3.so
zip -9 ../../dist/llama_cpp_ssse3.zip embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot convert*.py libllama_ssse3.so
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
