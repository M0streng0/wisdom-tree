<p align="center">

[![Downloads](https://pepy.tech/badge/wisdom-tree)](https://pepy.tech/project/wisdom-tree)
[![Downloads](https://pepy.tech/badge/wisdom-tree/month)](https://pepy.tech/project/wisdom-tree)
[![Downloads](https://pepy.tech/badge/wisdom-tree/week)](https://pepy.tech/project/wisdom-tree)

</p>

This fork is an implementation of both [bonsai.sh](https://gitlab.com/jallbrit/bonsai.sh) and [https://github.com/HACKER097/wisdom-tree](Wisdom Tree)

# Showcase

NOT YET

# Screenshots

NOT YET

# Wisdom Tree

Wisdom Tree is a tui concentration app. Inspired by the wisdom tree in Plants vs. Zombies which gives in-game tips when it grows, Wisdom Tree gives you real life tips when it grows. How can you grow the tree? by concentrating!

## Installation

Wisdom-tree uses vlc to play music, please make sure vlc is installed. 

Extra step for mac `brew install sdl2_mixer`

Extra step for Windows `pip install windows-curses` or `pipx inject wisdom-tree windows-curses`

### Installation from PyPi

`pip install wisdom-tree` or `pip3 install wisdom-tree`

### Installation using [pipx](https://pypa.github.io/pipx/)

`pipx install wisdom-tree`

This allows you to run the app from anywhere

### Installation From Github

`git clone https://github.com/M0streng0/wisdom-tree`

`cd wisdom-tree`

`pip install -r requirements.txt`
or
`pip3 install -r requirements.txt`

### Running the app

- From anywhere after installation from PyPi or using pipx

`wisdom-tree`

- From the github repository (root):

`python3 wisdom_tree/main.py`

*note the underscore*

or

`wisdom-tree`

## Usage

Use `left` and `right` arrow keys to change music

To add your own music, place it inside the `res/` directory (all music must be in `.ogg` format)

Use `up` an `down` arrow keys an `enter` to select and start Pomodoro timers.

While using lofi-radio use `n` to skip song and `r` to replay

`[` and `]` to increase and decrease the music/ambience volume respectively

`{` and `}` to increase and decrease the sound effect volume respectively

*You can replace arrow keys with vim's navigation keys (hjkl)*

`m` to mute music.

`r` to toggle repeat.

`u` to toggle q[u]iet mode, which mutes growth sounds and timer start sounds.

`space` to pause and unpause.

`+`, `-` to seek 10 sec forwards and backwords

number keys `0-9` to go 0-90% into the audio. Eg; pressing 6 will take you 60% into the audio, 7 will take you 70% and so on.

To exit press `q`

### Custom quotes

The user can use any set of quotes by adding a file called `qts.txt` with
one qoute per line to the default config location:

{`CONFIG_LOCATION`}/wisdom-tree

where {`CONFIG_LOCATION`} is the default place to save configuration files
for the operating system:

- windows: The folder pointed to by `LOCALAPPDATA` or `APPDATA`
- mac/linux: The folder pointed to by `XDG_CONFIG_HOME` or `~/.config`

*for now, adding a custom quotes file disables the default quotes*


## Features

Wisdom tree plays a variety of music, environmental sounds and white noises to help you concentrate. You can also import your own music into Wisdom Tree.

3000+ quotes and lines of wisdom. You are assured that you will never see the same quote again

Minimal interface and navigation to increase concentration.

Pomodoro timer

Play music from youtube

Lo-Fi radio

# Bonsai.sh

bonsai.sh is a bonsai tree generator for the terminal, written entirely in bash. It intelligently creates, colors, and positions the tree. My version is a modification of the original.

## Installation

Not necessary, just runnig the bash script.

## Usage

Run the command `./tree_generator.sh` to start the script to create all the necessary steps for later use with wisdom tree.

This code is going to generate `n` files, depending on the number of the steps for generating the bonsai tree. Each step corresponds to a year (within Wisdom Tree) of age.