#!/bin/bash

ROOT="/opt/vm/raw-to-docker"

# Per Run
IN="images/ROCKY8-ALCES-2021.0-2206211559_generic.raw"
OUT="rocky8sf-$(date +%d%m%y%H%M)"
CONF="docker/DockerfileRocky8"


START=$(parted $IN unit b print -m |grep "^2"  |awk -F ':' '{print $2}' |sed 's/B$//g')

mount -o loop,ro,offset=$START $IN convert/

cd convert/
tar -czf $ROOT/build/$OUT.tar.gz .
cd ..
umount convert

cd build/

cat << EOF > Dockerfile
FROM scratch
ADD $OUT.tar.gz /

CMD ["/bin/bash"]
EOF

docker build -t $OUT .
cd ..

mv build/$OUT.tar.gz tar/$OUT.tar.gz

echo "Run a test instance (will be deleted on disconnect):"
echo "  docker run -it --rm $OUT"
