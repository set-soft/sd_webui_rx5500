# Stable Diffusion WebUI docker images for RX5500XT and similar boards

This project creates [docker images](https://www.docker.com/) ([wiki](https://en.wikipedia.org/wiki/Docker_(software)))
to run the [AUTOMATIC1111](https://github.com/AUTOMATIC1111/stable-diffusion-webui)
[Stable Diffusion](https://stability.ai/blog/stable-diffusion-public-release) ([wiki](https://en.wikipedia.org/wiki/Stable_Diffusion))
web interface on Linux systems equiped with AMD Radeon
[RX5500XT](https://www.amd.com/es/support/graphics/amd-radeon-5500-series/amd-radeon-rx-5500-series/amd-radeon-rx-5500-xt)
and similar boards (i.e. RX5600XT, RX5700XT).

The main features of these docker images are:
- Ready to be used with RX5500XT (all needed options and compatible tools)
- Small size, when compared to other options (2.5 GB compressed image, 10.5 GB uncompressed, for the soft)
- No need to mess your base OS (no need to install stuff on your base system)

Some remarks to avoid confusion:
- For Linux systems, not for Windows
- For AMD GPUs, not for NVidia
- All software included, not the data files, they will be downloaded by the software
  You'll need not less than 5 GiB of extra disk space.
- Default config is for boards eith 8 GB of memory. Can run on 4 GB
- This is an image generator using AI networks, not a text generator
- Check how old is this README.md file, things change very fast in this field, if the file is old be
  careful, may contain inaccurate content

## Pre requisites

- A machine with an AMD Radeon GPU board, ideally RX5500XT.
  This board was released in 2019, forget about using anything older than RX470 (2016).
- At least 4 GB of VRAM (Video RAM)
- I'm not sure about how much system memory, I used 16 GB RAM and you'll need some swap
- A modern Linux kernel with the *amdgpu* driver.
  I used a 5.10.178 kernel from Debian 11.
  You can install an updated *amdgpu* driver, I tried with 5.18.2.22.40-1504718.20.04, but couldn't find
  any difference.
  To check if the driver is working run *ls -la /dev/kfd* you should see device owned by *root* for the
  *render* group
- Docker engine, otherwise [install](https://docs.docker.com/engine/install/) it
- Your Linux user must be in the *video* and *render* groups. Run the *groups* command to verify it

## Quick instructions

1. Clone this repo, or just download the
   [start_webui.sh](https://github.com/set-soft/sd_webui_rx5500/blob/main/docker/start_webui.sh)
   script.
2. Pull the docker images (here is how to [install](https://docs.docker.com/engine/install/))
```
$ docker pull setsoft/sd_webui:latest
```
3. Create a directory called *dockerx* in your user home dir, i.e. *mkdir -p $HOME/dockerx*.
   You can change the name editing the start script, not recommended
4. If you have 4 GB of GPU memory you must edit *start_webui.sh* and change **--medvram** by **--lowvram**.
   If you have more than 8 GB you may want to remove **--medvram** option, but I recommend to first
   try keeping it.
5. Run the *start_webui.sh* script.
6. Wait until it says you can connect to 127.0.0.1:7860 port.
   During the first run it will download 4 GB of data for the neural network weights, be patient.
   Just loading the data to the VRAM is slow, on my system it can take upto 80 seconds to load, usually
   around 46 s.
7. Open the indicated URL in your browser, you'll get the UI
8. Enter something in the positive prompt text box and press the generate button.
   The first run after starting the server will take longer, around 3 or 4 minutes in my system.
   Then the time will go down, 14 s aprox. for my system.
   Also note that the first generation will need more memory, so don't start changing the image size, keep
   it low for the first generated image
9. Have fun!
