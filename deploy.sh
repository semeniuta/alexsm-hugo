#!/bin/sh

# Create a temporary directory
temp_public_dir="/tmp/hugo_public_$RANDOM"
mkdir $temp_public_dir

# Generate site
hugo -d $temp_public_dir

# Sync the changes with the local public directory
rsync -tdvz --delete $temp_public_dir/ public

# Copy files from the public directory 
# to ~/alexsm/hugo_public of the server
rsync -avz --delete $temp_public_dir/ alex@alexsm.com:/home/alex/alexsm/hugo_public

# Remove the temporary directory
rm -rf $temp_public_dir
