#!/usr/bin/env bash
# Language slug -> container image.
#
# The language slug comes from courses/<slug>/.shipthatcode.json, so the
# toolchain is resolved from what the course actually teaches. Nothing is ever
# installed on the host.
#
# Two mechanisms:
#   stc_lang_image  a ready-made public image, used directly
#   stc_lang_apt    debian packages; stc builds+caches a tiny local image
#                   named stc-lang-<slug> from debian:stable-slim
# A language with neither is not runnable locally -- grade it on the site.
#
# The list mirrors the languages courses/*/run_tests.sh knows how to drive.

STC_APT_BASE="debian:stable-slim"

stc_lang_image() {
  case "$1" in
    c|cpp|fortran|objc)     echo "gcc:14" ;;
    rust)                   echo "rust:1-slim" ;;
    go)                     echo "golang:1" ;;
    python)                 echo "python:3.12-slim" ;;
    javascript|typescript)  echo "node:22" ;;
    java)                   echo "eclipse-temurin:21-jdk" ;;
    ruby)                   echo "ruby:3" ;;
    php)                    echo "php:8-cli" ;;
    perl)                   echo "perl:5" ;;
    haskell)                echo "haskell:9" ;;
    elixir)                 echo "elixir:1" ;;
    erlang)                 echo "erlang:26" ;;
    ocaml)                  echo "ocaml/opam:debian-ocaml-5.1" ;;
    swift)                  echo "swift:5" ;;
    clojure)                echo "clojure:temurin-21-tools-deps" ;;
    groovy)                 echo "groovy:jdk21" ;;
    scala)                  echo "sbtscala/scala-sbt:eclipse-temurin-21.0.2_13_1.9.9_2.13.13" ;;
    r)                      echo "r-base" ;;
    octave)                 echo "gnuoctave/octave:9.2.0" ;;
    csharp|vbnet)           echo "mono:6.12" ;;
    fsharp)                 echo "mcr.microsoft.com/dotnet/sdk:8.0" ;;
    d)                      echo "dlang2/dmd-ubuntu" ;;
    lisp)                   echo "clfoundation/sbcl:2.4.6" ;;
    *)                      echo "" ;;
  esac
}

stc_lang_apt() {
  case "$1" in
    # gcc + nasm + ld, for the `nasm -felf64 && ld` path in run_tests.sh
    assembly)  echo "nasm binutils gcc libc6-dev" ;;
    lua)       echo "lua5.4" ;;
    pascal)    echo "fp-compiler" ;;
    cobol)     echo "gnucobol4" ;;
    bash)      echo "bash coreutils" ;;
    *)         echo "" ;;
  esac
}

# Languages the platform grades but this setup can't reproduce locally, with the
# reason. run_tests.sh itself already refuses sql and prolog.
stc_lang_unsupported() {
  case "$1" in
    sql)    echo "run_tests.sh does not implement a local sql harness" ;;
    prolog) echo "run_tests.sh does not implement a local prolog harness" ;;
    kotlin) echo "kotlinc has no official image and needs an SDKMAN download" ;;
    basic)  echo "freebasic (fbc) is not packaged in debian" ;;
    *)      echo "" ;;
  esac
}
