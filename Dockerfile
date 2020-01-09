from alpine:edge

# intended for selectively disabling caching
arg version

run apk update
run apk add crystal musl-dev shards yaml-dev

run mkdir /root/loco
copy *.cr /root/loco/
copy shard.yml /root/loco/

workdir /root/loco
run shards install
run crystal build --release --static bakl.cr
run crystal build --release --static clom.cr
run crystal build --release --static tosm.cr
run crystal build --release --static ysnp.cr
run crystal build --release --static zenv.cr
