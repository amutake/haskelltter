#!/bin/bash

git submodule init
git submodule update
cd lib/twitter-types
cabal install
cd ../twitter-conduit
cabal intall
cd ../../
cabal install
