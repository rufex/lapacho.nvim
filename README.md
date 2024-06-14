# Lapacho

Lapacho is a Neovim plugin designed to enhance session management by automatically saving and loading shada files according to the current Git branch.
This allows users to maintain separate shada files for different branches.

## What is a shada file?

From the original documentation:

>The ShaDa file is used to store:
>
>- The command line history.
>- The search string history.
>- The input-line history.
>- Contents of non-empty registers.
>- Marks for several files.
>- File marks, pointing to locations in files.
>- Last search/substitute pattern (for 'n' and '&').
>- The buffer list.
>- Global variables.

More information in the [official documentation](https://neovim.io/doc/user/starting.html#shada-file) or using `:help shada`.

## Session management

It is possible to use this plugin in conjunction with session management plugins like [auto-session](https://github.com/rmagatti/auto-session)

## Features

- Automatically save and load shada files based on the current Git branch.
- Manual commands to save and load shada files.
- Configurable options to disable automatic shada management.

## Why?

Basically, to link Marks to git branches. This is useful when you are working on different branches and want to keep your marks separated.

## [Lapacho](https://en.wikipedia.org/wiki/Handroanthus_impetiginosus)

![Lapacho](https://upload.wikimedia.org/wikipedia/commons/thumb/b/bb/Lapachos_rosados_en_Parque_Urquiza%2C_Rosario.jpg/1024px-Lapachos_rosados_en_Parque_Urquiza%2C_Rosario.jpg)

[Image by César Pérez - Own work, CC BY-SA 4.0](https://commons.wikimedia.org/w/index.php?curid=73233264)
