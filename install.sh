#!/bin/bash

cabal update
git submodule init
git submodule update
cd lib/twitter-types
cabal install
cd ../twitter-conduit
cabal install
cd ../../
cabal install
