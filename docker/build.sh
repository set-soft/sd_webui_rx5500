mkdir -p apt_debs/archives/partial
mkdir -p apt_files/lists/partial/
mkdir -p apt_files/lists/auxfiles/
docker build -f Dockerfile --progress plain -t setsoft/sd_webui:sd1.2.1_pt1.13.1_rocm5.2_d11.7 . 2>&1 | tee build.log
docker build -f Dockerfile --progress plain -t setsoft/sd_webui:latest . 2>&1 | tee build.log
