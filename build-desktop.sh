#!/bin/bash
#package-manager install git zip fakeroot
set -o errexit
set -o pipefail
# Parse options
clean=false

while [[ $# -gt 0 ]]; do
    case "$1" in
        -c|--clean)
            clean=true
            echo "cleaning build dirs"
            chmod -Rv 770 ./.cache
            rm -Rfv ./.cache
            chmod -Rv 770 ./desktop/node_modules
            rm -Rfv ./desktop/node_modules
            chmod -Rv 770 ./desktop/.vite
            rm -Rfv ./desktop/.vite
            rm -Rfv ./desktop/out
            chmod -Rv 770 ./web/dist
            rm -Rfv  ./web/dist
            chmod -Rv 770 ./web/node_modules
            rm -Rfv ./web/node_modules
            rm -v ./gomuks
            rm -v ./rpc.html
            rm -v ./web/src/api/types/stdcommands.json
            rm -v ./web/tsconfig.tsbuildinfo
            echo "{}" > ./desktop/src/build-info.json
            shift
            ;;
    esac
done


mkdir --parents --verbose .cache
export GOPATH="$PWD/.cache"
export GOCACHE="$PWD/.cache/build"
#export MAU_STATIC_BUILD=true
go run ./cmd/rpcdocgen -o rpc.html
cd web
go run ../pkg/hicli/cmdspec/print src/api/types/stdcommands.json src/api/types/stdcommands.d.ts
./build-wasm.sh
npm approve-scripts --all
npm clean-install --include=dev
npm approve-scripts --all
npm clean-install --include=dev
npm run build
cd ..
mkdir -p web/dist/_gomuks/codeblock
go run ./cmd/chromagen web/dist/_gomuks/codeblock/
./build-noweb.sh
cd desktop
npm approve-scripts --all
npm ci --include=dev
npm approve-scripts --all
npm run make --
npm approve-scripts --allow-scripts-pending
cd ..
