#!/usr/bin/env bash
targets=(tosm ysnp zenv)

for target in ${targets[@]}; do
    echo "Building $target"
    crystal build $target.cr
    echo "Linking $target"
    ln -fs $(realpath $target) $HOME/bin
done
