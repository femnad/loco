from alpine:3.10.1
run apk update
run apk add crystal musl-dev yaml-dev
run mkdir /root/loco
copy bakl.cr /root/loco
copy tosm.cr /root/loco
copy ysnp.cr /root/loco
copy zenv.cr /root/loco
workdir /root/loco
run crystal build --static bakl.cr
run crystal build --static tosm.cr
run crystal build --static ysnp.cr
run crystal build --static zenv.cr
