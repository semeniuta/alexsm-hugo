#!/bin/sh

# Regenerate files in public

rm -rf public/*
hugo

# Copy files from the public directory 
# to ~/alexsm/hugo_public of the server

rsync -avz public/ alex@alexsm.com:/home/alex/alexsm/hugo_public