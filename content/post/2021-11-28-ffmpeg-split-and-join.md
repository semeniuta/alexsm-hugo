---
layout: post
title: Automatically split and join a video using ffmpeg 
comments: true
slug: ffmpeg-split-and-join
date: "2021-11-28"
tags: [ffmpeg, bash]
---

This summer I had a task of processing a large collection of videos that I recorded myself while teaching a course at NTNU. Most parts of the videos contained the content I wanted to preserve, but I wanted to cut away some small portions and, additionally, split the big video files into a series of smaller ones. Surely, I wanted to do this programmatically using [**ffmpeg**](https://ffmpeg.org/). In this blog post I am going to summarize my experience with this task.

My overall workflow was quite simple: I was rewatching the videos in VLC and recorded timestamps I wanted to cut away in a text file. Once I was done with a portion of the original file that would further constitute a smaller clip with removed "bad" parts, I ran a bash script utilizimg **ffmpeg** to cut the big video in a set of smaller ones and then assemble them back in one single file. 

My approach to recording timestamps was to create a line for each "good" small portion of the video I wanted to produce, delimited with a starting and ending timestamp im the format of `HH:MM::SS`:

```
01:26:10 01:44:04
01:44:28 01:44:55
01:45:23 01:56:39
```

Once such file was ready, I applied the following [script](https://github.com/semeniuta/alexsm-scripts/blob/master/videoca.sh):

```bash
#!/bin/sh

video_file=$1
timestamps_file=$2
tmp_dir="$HOME/Desktop/tmp"
filelist="$tmp_dir/filelist.txt"

mkdir "$tmp_dir"

echo "Video cutting and assembling: $video_file"
echo "Timestamps file: $timestamps_file"

counter=0
echo "" > "$filelist"
commands=()

while read -r line
do
    # Make array from the line (space-separated timestamps)
    timestamps=($line)
    
    clip_start=${timestamps[0]}
    clip_end=${timestamps[1]}

    # Cut video section with slower seek & no copying of codecs
    cmd="ffmpeg -y -i $video_file -ss $clip_start -to $clip_end $tmp_dir/$counter.mp4"
    
    commands+=("$cmd")

    echo "file '$counter.mp4'" >> "$filelist"

    ((counter++))

done < "$timestamps_file"

# Execute each command for cutting video sections
for cmd in "${commands[@]}"
do
    echo "$cmd"
    eval "$cmd"
done

# Merge clips into one file if more than one clip is available
if [ ${#commands[@]} -gt 1 ]; then
    ffmpeg -y -f concat -safe 0 -i "$filelist" -c copy "$tmp_dir/merged.mp4"
fi
```

Let's look at what the script does. First, it read two command line arguments, with the first (`$1`) containing the path to the video file and with the second (`$2`) storing the path to the file with the timestamps. Lazily enough, I created a temporary directory on Desktop where I was storing the intermediate files as well as a single resulting video file. 

The timestamps file is parsed, and for each pair of the timestamps, an **ffmpeg** command is constructed to cut a small portion of the video:

```bash
ffmpeg -y -i $video_file -ss $clip_start -to $clip_end $tmp_dir/$counter.mp4
```

Each run of this command creates a file in the temporary directory starting with `0.mp4` and onward. Options of **ffmpeg** for this command are listed below:

 * ` -y` overwrite output files without asking
 * ` -i` input file
 * `-ss` start position
 * `-to` end position

Additionally, we are automatically populating a text file containing paths to the small video files we will later concatenate. For the example with three such file, `filelist.txt` will look as follows:

```
file 0.mp4
file 1.mp4
file 2.mp4
```

In the number of small files is greater than 1, they are concatenated using the following command:

```bash
ffmpeg -y -f concat -safe 0 -i "$filelist" -c copy "$tmp_dir/merged.mp4"
```

where `$filelist` stores the path to `filelist.txt` and the used options are the following:

* `-f concat` format = concatenation 
* `-safe 0` any file name is accepted
* `-c copy` codec = copy the frames

As such, once I have the timestamps file (say, in the current directory), I invoke the script as follows (`videoca.sh` stands for "video cut and assemble"):

```bash
videoca.sh /path/to/bigvideo.mp4 timestamps.txt
```

After the processing is done, the temporary folder will contain the resulting file `merged.mp4`, along with the intermediate files that can be safely deleted. 

Other nice tutorials about use cases of **ffmpeg**:

 * [Read and Write Video Frames in Python Using FFMPEG](http://zulko.github.io/blog/2013/09/27/read-and-write-video-frames-in-python-using-ffmpeg/)
 * [Trim video files using FFmpeg](https://www.arj.no/2018/05/18/trimvideo/)
 * [Convert .mov to .mp4 with ffmpeg](https://mrcoles.com/convert-mov-mp4-ffmpeg/)
