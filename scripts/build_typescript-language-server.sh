#!/bin/bash
set -e

if [ -z $1 ]
then
  echo No version specified
  exit 1
fi

if [ -z $2 ]
then
  echo No target specified
  exit 1
fi

version="$1"
target="$2"
output_dir="../../output"
_scratch=`mktemp -d ./tmp.XXXXXXXXXX`
scratch=`realpath "$_scratch"`

function finish {
  rm -rf "$scratch"
}
trap finish EXIT

cd "$scratch"

curl -L -o "v$version.tar.gz" "https://github.com/typescript-language-server/typescript-language-server/archive/refs/tags/v$version.tar.gz"

tar -xzvf "v$version.tar.gz"
cd "typescript-language-server-$version"

yarn add --dev pkg
npm pkg delete 'bin'
npm pkg set 'bin.typescript-language-server'='./lib/cli.cjs'
npm pkg set 'pkg.assets[]'='package.json' 'pkg.assets[]'='node_modules/typescript/**/*.js' 'pkg.assets[]'='node_modules/typescript/**/*.json'

patch <<EOF
diff --git a/rollup.config.ts b/rollup.config.ts
--- a/rollup.config.ts
+++ b/rollup.config.ts
@@ -9,8 +9,8 @@ export default defineConfig({
     output: [
         {
             banner: '#!/usr/bin/env node',
-            file: 'lib/cli.mjs',
-            format: 'es',
+            file: 'lib/cli.cjs',
+            format: 'cjs',
             generatedCode: 'es2015',
             plugins: [
                 terser(),
EOF

yarn
yarn build

mkdir -p "$output_dir"
node_modules/pkg/lib-es5/bin.js package.json --out-path "$output_dir" --target="$target" --compress=GZip
chmod +x "$output_dir"/*
