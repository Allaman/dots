#!/usr/bin/env bash

atuin login -u allaman -p "$(gopass show atuin/pass)" -k "$(gopass show atuin/key)"
