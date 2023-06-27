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
# Force the use of the dynamic lib, we will create a set of executables and various libs
sed -i -e 's/build-info.h ggml.o llama.o \(.*\)\$(OBJS)/build-info.h libllama.so \1/' Makefile
# First pass create a very generic binary
# Create the dynamic lib and executables
LLAMA_HIPBLAS=1 make -j4
mkdir ../../dist/
strip --strip-unneeded libllama.so embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot
mv libllama.so ../../dist/libllama_generic.so
zip -9 ../../dist/llama_cpp_programs.zip embedding main perplexity quantize quantize-stats simple train-text-from-scratch vdot convert*.py
make clean
LLAMA_CUDA_DMMV_X=64 LLAMA_CUDA_DMMV_Y=4 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_generic_64x4.so
make clean
LLAMA_CUDA_DMMV_X=128 LLAMA_CUDA_DMMV_Y=8 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_generic_128x8.so
make clean
# 2nd pass create AVX optimized binary
sed -i -e 's/OPT = .*/OPT = -O3 -mfma -mf16c -mavx/' Makefile
LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_avx.so
make clean
LLAMA_CUDA_DMMV_X=64 LLAMA_CUDA_DMMV_Y=4 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_avx_64x4.so
make clean
LLAMA_CUDA_DMMV_X=128 LLAMA_CUDA_DMMV_Y=8 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_avx_128x8.so
make clean
# 3rd pass create an SSSE3 optimized binary
sed -i -e 's/OPT = .*/OPT = -O3 -mssse3/' Makefile
LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_ssse3.so
make clean
LLAMA_CUDA_DMMV_X=64 LLAMA_CUDA_DMMV_Y=4 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
mv libllama.so ../../dist/libllama_ssse3_64x4.so
make clean
LLAMA_CUDA_DMMV_X=128 LLAMA_CUDA_DMMV_Y=8 LLAMA_HIPBLAS=1 make -j4 libllama.so
strip --strip-unneeded libllama.so
cp libllama.so ../../dist/libllama_ssse3_128x8.so
# No clean, we will use the SSSE3 with 128x8, the best for my system, quite basic
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
