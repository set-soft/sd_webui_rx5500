# Stable Diffusion WebUI docker images for RX5500XT and similar boards

This project creates [docker images](https://www.docker.com/) ([wiki](https://en.wikipedia.org/wiki/Docker_(software)))
to run the [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
[Stable Diffusion](https://stability.ai/blog/stable-diffusion-public-release) ([wiki](https://en.wikipedia.org/wiki/Stable_Diffusion))
web interface on Linux systems equiped with AMD Radeon
[RX5500XT](https://www.amd.com/es/support/graphics/amd-radeon-5500-series/amd-radeon-rx-5500-series/amd-radeon-rx-5500-xt)
and similar boards (i.e. RX5600XT, RX5700XT).

The main features of these docker images are:
- Ready to be used with RX5500XT (all needed options and compatible tools).
- Small size, when compared to other options (PyTorch 2: 3.89 GB compressed, 13.4 GB uncompressed,
  PyTorch 1: 2 GB compressed image, 10.2 GB uncompressed, for the whole soft).
- No need to mess your base OS (no need to install stuff on your base system).
- Already created, one download and all the software is installed.

Some remarks to avoid confusion:
- For Linux systems, not for Windows
- For AMD GPUs, not for NVidia.
- All software included, not the data files, they will be downloaded by the software.
  You'll need not less than 5 GiB of extra disk space. Control Net needs another 21 GB.
- Default config is for boards with 8 GB of memory. Can run on 4 GB.
- This is an image generator using AI networks, not a text generator.
- Check how old is this README.md file, things change very fast in this field, if the file is old be
  careful, may contain inaccurate content.

## Pre requisites

- A machine with an AMD Radeon GPU board, ideally RX5500XT.
  This board was released in 2019, forget about using anything older than RX470 (2016).
- At least 4 GB of VRAM (Video RAM)
- I'm not sure about how much system memory, I used 16 GB RAM and you'll need some swap.
- A modern Linux kernel with the *amdgpu* driver.
  I used a 6.1.106 kernel from Debian 12 and a 5.10.178 kernel from Debian 11.
  You can install an updated *amdgpu* driver, I tried with 5.18.2.22.40-1504718.20.04, but couldn't find
  any difference. In fact I didn't do it for the 6.1 kernel.
  To check if the driver is working run *ls -la /dev/kfd* you should see a device owned by *root* for the
  *render* group
- Docker engine, otherwise [install](https://docs.docker.com/engine/install/) it.
- Your Linux user must be in the *video* and *render* groups. Run the *groups* command to verify it.

## Quick instructions

1. Clone this repo, or just download the
   [start_webui.sh](https://github.com/set-soft/sd_webui_rx5500/blob/main/docker/start_webui.sh)
   script.
   ([start_webui_low.sh](https://github.com/set-soft/sd_webui_rx5500/blob/main/docker/start_webui_low.sh)
   for a 4 GB board).
2. Pull the docker image:
```
$ docker pull setsoft/sd_webui:latest
```
3. Create a directory called *dockerx* in your user home dir, i.e. *mkdir -p $HOME/dockerx*.
   You can change the name editing the start script, not recommended.
4. If you have 4 GB of GPU memory you must use *start_webui_low.sh*, otherwise use *start_webui.sh*.
   If you have more than 8 GB you might want to remove **--medvram** option, but I recommend to first
   try keeping it.
5. Run the *start_webui.sh* or *start_webui_low.sh* script.
6. Wait until it says you can connect to 127.0.0.1:7860 port.
   During the first run it will download 4 GB of data for the neural network weights, be patient.
   Note that PyTorch 1 images (SD WebUI v1.2 and v1.3 images) takes time to load the data to the VRAM,
   on my system it can take upto 80 seconds to load, usually around 46 s. The PyTorch 2 images (SD WebUI
   1.10) are fast, the load takes a few seconds.
7. Open the indicated URL in your browser, you'll get the UI
8. Enter something in the positive prompt text box and press the generate button.
   The first run after starting the server will take longer. The PyTorch 1 images needs around 3 or 4
   minutes for my system, the PyTorch 2 images just a few extra seconds.
   Then the time will go down, 14 s aprox. for my system.
   Also note that the first generation will need more memory, so don't start changing the image size, keep
   it low for the first generated image.
9. Have fun!

All the data will be stored in the *~/dockerx/* folder. Take a look at *~/dockerx/webui_data/* for the
web interface data. The *~/dockerx/cache/* is the cache for the system running inside the container.
Generated stuff will be stored in *~/dockerx/webui_data/outputs*. The downloaded AI data can be found in
*~/dockerx/webui_data/models*.

If you want to use Control Net, it makes things better, you'll need to download the models for it in:
*~/dockerx/webui_data/models/ControlNet*. Please [visit the site](https://github.com/Mikubill/sd-webui-controlnet)
to learn more. Also visit the [main site](https://github.com/lllyasviel/ControlNet-v1-1-nightly) to know how to
use it.

## Technical details

### Software stack

#### Linux kernel and device driver

At the bottom of the stack is the Linux kernel. I tested this image using 6.1.106 and 5.10.178.
The kernel must provide the [DRM](https://en.wikipedia.org/wiki/Direct_Rendering_Manage)
(Direct Render Manager) interface for AMD GPUs. This is the *amdgpu* kernel module.

This module is part of the mainstream Linux kernel, no need to add anything.
If your kernel doesn't have it, or the version included in the kernel isn't good enough you might need
to install a newer version. Lamentably the version of the *amdgpu* driver isn't displayed by the
module included in mainstream Linux, not at least for my kernel. If you install a separated version it
will display it. For a 5.10.x kernel with *amdgpu* 5.18.2.22.40 you'll see the following in the kernel
logs: (sudo dmesg | grep version)

```
[drm] amdgpu version: 5.18.2.22.40
[drm] OS DRM version: 5.10.0
```

The [*amdgpu*](https://en.wikipedia.org/wiki/AMDgpu_(Linux_kernel_module)) development is done by AMD and
evolves much faster than what is incorporated by the Linux kernel. So you'll find newer features
implemented. It doesn't mean this is best for you because some times these features makes the module
incompatible. As an example: installing version 6.0.5 on Debian 11.7 produces tons of logs about fails to
call the page flip API.

If you need to compile a new *amdgpu* module look for the *amdgpu-install* tool.
AMD provides a [repo](https://repo.radeon.com/amdgpu-install/) for the officially supported Linux distros.
I tried using the Ubuntu Focal Debian packages, version 5.3.3.

An important note: in order to compile the module you'll need to use
[DKMS](https://en.wikipedia.org/wiki/Dynamic_Kernel_Module_Support) (Dynamic Kernel Module Support).
So the correct way to run the installer is:

```
amdgpu-install --usecase=dkms
```

Do not follow the misleading instructions that says **--usecase=rocm**. This will install several GBs of
code into your host machine, that will be repeated in the docker image.

I experimented very bizarre issues
trying to compile the module in my system. The long version name used by AMD in combination with the way
my installed DKMS created the makefiles generated some calls passing a single argument bigger than 128 kB,
a stupid Linux kernel limit, and made the compilation fail. So instead of compiling it in
*/var/lib/dkms/amdgpu/5.18.2.22.40-1504718.20.04/* I forced DKMS to use
*/v/amdgpu/5.18.2.22.40-1504718.20.04/*. This solved the problem. If you hit the same problem do the
following:

1. Create a symlink like this **ln -s /var/lib/dkms/ /v** (as root of course)
2. Edit */etc/dkms/framework.conf* and set **dkms_tree="/v"**
3. Compile again (i.e. *dpkg-reconfigure --force amdgpu-dkms*)

Note that the DRM interface will be seen in your system as a
[DRI](https://en.wikipedia.org/wiki/Direct_Rendering_Infrastructure) (Direct Render Infrastructure)
device driver. As an example in a Debian system you'll see something like this:

```
$ ls -la /dev/dri
total 0
drwxr-xr-x   3 root root        100 abr 30 19:53 .
drwxr-xr-x  20 root root       3960 abr 30 19:54 ..
drwxr-xr-x   2 root root         80 abr 30 19:53 by-path
crw-rw----+  1 root video  226,   0 may  6 09:48 card0
crw-rw----+  1 root render 226, 128 abr 30 19:53 renderD128
```

As you can see the user needs to be in the **video** and **render** groups in order to be able to access
all the devices. Run *groups* to check it.

Also note that DRM is not enough for this use, your *amdgpu* driver must also export the AMD
Kernel Fusion Driver (KFD) interface. Here is an example of how to check it:

```
$ ls -la /dev/kfd
crw-rw---- 1 root render 246, 0 abr 30 19:53 /dev/kfd
```

If this device isn't there your board doesn't support KFD and won't work.

Also note that you don't need any proprietary kernel module, even if you install a separated *amdgpu*
module it will be compiled from sources. The only proprietary component you should install is the
firmware for your GPU card. This is already installed if you have a working graphic interface in your
Linux. Without it you don't even get an accelerated desktop. Note that most Linux distros will install
it without any effort, Debian is an exception. As source code for these firmwares isn't available
(don't ask me why because the code is very hardware dependant and a lot of technical info about the GPU
is already disclosed) Debian puts it in a separated category. You must install the
*firmware-amd-graphics* package from the *non-free* repository. The RX5500XT board is internally named
Navi14 so the kernel messages generated when loading the firmware will look like this:

```
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_sos.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_asd.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_ta.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_smc.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_pfp.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_me.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_ce.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_rlc.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_mec.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_mec2.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_sdma.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_sdma1.bin
amdgpu 0000:0a:00.0: firmware: direct-loading firmware amdgpu/navi14_vcn.bin
```

#### ROCm

[ROCm](https://en.wikipedia.org/wiki/ROCm#ROCk_-_Kernel_driver) is the infrastructure created by AMD to
use their GPUs for computation. This includes the
[Machine Learning](https://en.wikipedia.org/wiki/Machine_learning) (ML), which is what we want to do here.

This component is huge for many reasons, among them:

- Cover a big number of uses, not just ML
- Supports various GPU generations, with a weak separation between the low level components
- Is high level code written in C++. IMHO a wrong choice, I can't imagine a Linux kernel in C++, it won't
  work for embedded systems. I agree that some layer of C++ is desirable, but the core functionality
  should be plain C, with an optional C++ abstraction layer. People usually think C++ is close to C, but
  in practice it isn't, when you start using the STL things start to drift away from C. The code
  generated is repeated again and again and you can get huge binaries.

If you are just using ROCm for Stable Diffusion installing the whole thing is an overkill.
For this reason this docker image isn't based on the ROCm images. Just to put you in perspective:
ROCm images with PyTorch are in the range of 10 GB compressed, around 30 GB uncompressed.
This image is around 2 GB, 10 GB uncompressed, and includes the final application.
The PyTorch 2 image is around 3.9 GB, and 13.4 GB uncompressed.

You don't need to install ROCm in your host, unless you use ROCm for other tasks. Also note that
installing ROCm in your host won't help to the docker images, they'll have another copy, or even more
than one, of ROCm. If you really need ROCm consider installing the other layers in your host and forget
about docker images.

You won't find ROCm as a separated component on this docker image, is integrated with the next layer.


#### PyTorch

[PyTorch](https://en.wikipedia.org/wiki/PyTorch) is the machine learning framework we need to install.
Is a Python API originally created by META (Facebook), currently free software. Note that this works
on top of Torch, a free software component created by a university.

This is the most widely used ML lib and Stable Diffusion uses it. It offers three flavors:

- CPU
- CUDA
- ROCm (HIP Heterogeneous(-compute) Interface for Portability)

Here we need ROCm flavor.

##### PyTorch 1

Lamentably I couldn't find a better way than installing it using *pip* (the
Python package manager). This has really nasty consequences. As I already mentioned ROCm is in this layer.
The Python way to solve dependencies makes this a "normal" solution. So when you install PyTorch for ROCm
you are installing PyTorch compiled with ROCm support **and** ROCm, all together. This is why the
compressed size of the PyTorch wheel (the name of the Python packages) is around 1.5 GB.

##### PyTorch 2

Last year I couldn't make PyTorch 2 work. But now I'm using as base a
[docker image](https://github.com/serhii-nakon/rocm_gfx1012_pytorch) compiled by
[@serhii-nakon](https://github.com/serhii-nakon).
This docker image contains a [patched ROCm](https://github.com/xuhuisheng/rocm-build) with gfx1012
support (Navi14 support), cortesy of [Xu Huisheng](https://github.com/xuhuisheng).

The images contains PyTorch 2.2.0 compiled with ROCm 5.4.3 with the native support.
They are bigger because more work is needed to polish them. But they solve two major issues:

1. Very slow start-up (46 to 80 seconds in my system). You get the SD WebUI up in just seconds, not minutes
2. No need to use 32 bits floating point, you can use 16 bits. Lamentably this doesn't mean you
   get better performance, but you save a lot of VRAM.

#### Other Pyhon libs

There are a big ammount of dependencies installed in the docker image. In order to satisfy the really
fresh dependencies they are installed using pip (very inefficient). Among the heavy weight tools are
llvmlite, scipy, OpenCV, gradio, pandas, transformers and numpy. But all of them are eclipsed by the
PyTorch package, which includes ROCm, this is around 75% of the image size.

The [OpenCV](https://pypi.org/project/opencv-python/) lib needs some special attention. It has a very
bad separation between GUI vs non-GUI and mainstream vs contrib separation. The problem is aggrieved by
the way *pip* works. So you have four possible packages, and you may end with all of them installed,
meaning the core OpenCV is four times installed, and the GUI libs twice, not to mention that the contrib
stuff is also twice times installed. In our particular case we get two copies installed, and none of them
is the best for a docker image. For this reason the *Dockerfile* lets *pip* to wrongly install them and
then removes both to install the one we need (*opencv-contrib-python-headless*).

This part of the stack can be farther optimized.

#### Stable Diffusion WebUI by AUTOMATIC1111

This is the application we want to run. Is implemented as a web server using the
[gradio](https://gradio.app/) module, specifically designed to create ML applications.

The application implements a lot of interesting tools, mostly using existing projects, and is extensible.
Among the built-in features are:

- Text to image, used to generate images from a description. Supports negative prompts, various sampling
  methodes, batch generation, etc. This is implemented using Stable Diffusion.
- Image to image, used to create an image from another image. Some features:
  - Interrogate using CLIP and DeepDanbooru: generates a prompt from an image
  - Inpaint: allows to generate a portion of the image to solve issues or just change some detail
- Face restoration
- Upscalers, using mathematic algorithms and also AI
- Training models and merging models

You'll find a more complete list in its [site](https://github.com/AUTOMATIC1111/stable-diffusion-webui).

The server will run in the docker container and you just need to connect to the server using a browser.
The default is to export the interface to the local machine: http://127.0.0.1:7860 accepting connections
only from the local host, but can be exported to other machines.

#### Conclusion

This is an state of the art AI powered image generator. The webui is like an AI laboratory because it's
extensible and gradio was designed for this. The AUTOMATIC1111 implementation is very complete and easy
to use. Neural networks are automatically downloaded, you must pay attention to the console where the
server was started to see the progress.

The installation is simple, but can be tricky for AMD boards. Using a docker image allows to solve various
common problems.

The amount of misleading instructions and bloated installs is notable. AMD seems to be focused on the
servers applications of ROCm, so they don't spend enough resources to help regular users.

### Optimizations and options

If you take a look at the original [Stable Diffusion v1](https://github.com/CompVis/stable-diffusion)
you'll see it says: *runs on a GPU with at least 10GB VRAM*,
and in the fast mode this code doesn't even work on an RX5500XT with 8 GB.
So memory requirements are very important. You can currently run it on 4 GB, and even some report success
with 2 GB (not for RX5500XT). A number of options has important impact on the memory usage and performance.
Here are some thing you may need to know.

The optimizations are documented [here](https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Optimizations).
I focuse on what is good for RX5500XT, and maybe other similar boards.

#### Floating point format

This was a problem when we didn't have a patched ROCm, so this only applies to the PyTorch 1 images.

The traditional *float* data type in C is a 32 bits floating point number (F32). For ML you can do
computations with much less resolution. So you'll find a lot of libraries using *half precision* numbers,
this is a 16 bits floating point (F16).

The RX5500XT board, and other AMD GPUs, can't do F16 computations. So you must force the use of F32.
This has an important impact in the memory usage.

The options: *--precision full* and *--no-half* are used to force F32 data computations.

#### Saving VRAM swapping data to the RAM

Using full precision means you'll need a lot of VRAM, even to generate one 512x512 image. So one of the
important strategies is to keep in VRAM only the needed stuff. You can parition the problem in stages
and upload one at a time.

The *--medvram* and *--lowvram* options are the most important here. The first is what I recommend for
an 8 GB board using full precision. This has a small impact on the computation time and big impact in
the memory usage. The second option is a very aggressive strategy with very big impact on the computation
time, only recommendable for 4 GB boards.

Another option is in the settings of the webui, you can ask to avoid keeping the face restoration net
in RAM when the process is done. Face restoration is very important, you don't need to enable it all the
time, you can generate the images and then go to the *extras* and apply it to the images you selected.
But having it enabled is nice and it usually takes just a little bit more time, the results are
remarkable. Note: 1.10.1 WebUI moved the face restoration away, and you only do it in extras.

When using *--medvram* or *--lowvram* one of the implicit optimizations is to put in VRAM only the
positive or the negative prompt, one at a time, never both together. This saves VRAM, but also means
moving a lot of data to and from VRAM. If you want to recover some performance, at the cost of VRAM, you
can try using *--always-batch-cond-uncond*. Using this both prompts are stored in VRAM during the whole
process. So this option makes *--medvram* and *--lowvram* less effective in terms of VRAM, but also
reduces the impact in performance. Note that this option is useless when you don't use *--medvram* or
*--lowvram*.

#### Sub-quadratic attention

This methode notably reduces the use of VRAM without slowing the computations.
Use *--opt-sub-quad-attention*

#### Host system RAM

The tools has some serious memory issues. If you run it for some hours you'll see how free memory slowly
falls until you have nothing available and the server is killed by the kernel. To avoid this problem you
must use an improved memory allocation library. The *libtcmalloc* library implements such an allocator.
Using it the memory leaks are kept low.

This library is installed in the docker image (libtcmalloc-minimal4) and is forced using the *LD_PRELOAD*
environment variable (`LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc_minimal.so.4`)

#### Unofficial ROCm support

This problem was solved by the patched ROCm, so only applies to the PyTorch 1 images.

The RX5500XT (aka Navi14) boards aren't officially supported by AMD. They are codenamed *gfx1012*, but if
you tell ROCm the board is a *gfx1030* things work anyways. The 1030, 1012, etc. is the version, so you
need to define the `HSA_OVERRIDE_GFX_VERSION=10.3.0` environment variable, which basically pretends your
board is version 10.3.0 and not 10.1.2.

#### Options that doesn't seem to help

I see many people suggesting *SAFETENSORS_FAST_GPU=1*, but this is a CUDA (NVidia) option to copy data
directly to VRAM, skipping a RAM stage. Not part of ROCm.

People also encourage using *PYTORCH_CUDA_ALLOC_CONF*, but again this is CUDA specific. Is well documented
in [PyTorch](https://pytorch.org/docs/stable/notes/cuda.html) as a mechanism to fine-tune the CUDA
allocation strategy. But isn't mentioned in the
[HIP (ROCm) semantics](https://pytorch.org/docs/stable/notes/hip.html). I think the confusion comes from
the error printed by PyTorch when you run out of VRAM, it mentions *PYTORCH_HIP_ALLOC_CONF*. Note the
difference, HIP, not CUDA. But I suspect this is some misleading print.

I tried the above mentioned variables and didn't notice any change, which is understandable.
The option is included anyways.

Other people suggests using *--disable-nan-check*. I couldn't see any measurable difference using it for
RX5500XT, and it sounds like a bad idea, a [NaN](https://en.wikipedia.org/wiki/NaN) is indication of
error, can be related to memory corruption.

#### Overclocking

The RX5500XT doesn't seem to be a board to overclock.

By default it runs at 1890 MHz, the PLL can do 2200 MHz. In my board 2050 MHz is usable, but
2100 MHz generates a memory access fault. Even at the highest Vdd.

The VRAM clock is 875 MHz and can be boosted to 930 MHz. I was able to set it to 930 MHz, but you
see an annoying video flicker, specially when moving the mouse.

With all of this I got a computation boost in SD of about 5 %. So I don't recommend to do it, the
flicker is annoying, and the advantage marginal. If you are really interested consult the
[kernel docs](https://docs.kernel.org/6.1/gpu/amdgpu/thermal.html) and articles like
[this](https://www.reddit.com/r/Amd/comments/agwroj/how_to_overclock_your_amd_gpu_on_linux/).
