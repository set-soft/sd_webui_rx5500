# VAE

Stands for [Variational AutoEncoder](https://en.wikipedia.org/wiki/Variational_autoencoder).
Is a neural network and is in charge of de/enconding the image into the
format used by the diffusion model, which is the *latent space*.

As what we usually use to start is just noise, the most common importance is
to extract the generated image from the *latent space*. This is why the VAE
affects the quality of the generated image.

Stable Diffusion model has two VAEs, using different probabilistic methods:

- EMA (Exponential Moving Average) for most applications, as it produces
  images that are sharper and more realistic.
- MSE (Mean Squared Error) smoother and less noisy, but less realistic

Diffusion models derived from SD can also have a special VAE. Sometimes the
VAE can be *baked* in the checkpoint. When we use the wrong VAE the image
can look foggy and/or desaturated.

The cases are:

1. The model works fine with SD VAEs
2. The model needs a special VAE, usually with a similar file name
3. The model has the VAE *baked*

The use of the VAE at the end of the generation might need extra memory and
ruin the process in the last step.

WebUI currently supports [TAESD](https://github.com/madebyollin/taesd)
(Tiny AutoEncoder for Stable Diffusion). This is a fast VAE suitable for Stable
Diffusion models. In many cases the different in result is small, but in some
cases is important.

You can save memory and time using TAESD, at the cost of quality.

Some numbers I got for a particular case:

Starting from 512x768 + HiRes fix

| Width | Height | VAE [GB] | TAESD [GB] |
| ----- | ------ | -------- | ---------- |
|   768 |   1152 |      5.2 |        4.3 |  884736  1572864/(7.6-4.3)
|   921 |   1382 |        ? |        5.2 | 1272822
|  1024 |   1536 |        ? |        5.8 | 1572864
|  1280 |   1920 |        ? |        7.6 | 2457600

Usage: 2.098085497e-06*pixels+2.44

1152x768 7.7/6.1

Starting from 960x540 + HiRes fix

- 1920x1080     6.3
- 1768x972    .....+Remacri works and much better quality


Ref: [What Is VAE in Stable Diffusion?](https://builtin.com/artificial-intelligence/stable-diffusion-vae)
