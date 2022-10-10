#!/usr/bin/env sh

sketchybar --add space web left                              \
           --set web  associated_display=1                    \
                      associated_space=1                      \
                      icon=                                 \
                      icon.highlight_color=0xfffab402         \
                      click_script="yabai -m space --focus 1" \
                                                              \
           --add space sh left                               \
           --set sh   associated_display=1                    \
                      associated_space=2                      \
                      icon=                                  \
                      icon.highlight_color=0xfffab402         \
                      click_script="yabai -m space --focus 2"  \
           --add space aux left                               \
           --set aux  associated_display=1                    \
                      associated_space=3                      \
                      icon=                                  \
                      icon.highlight_color=0xfffab402         \
                      click_script="yabai -m space --focus 3" \
           --add space fun left                               \
           --set fun  associated_display=1                    \
                      associated_space=4                      \
                      icon=                                  \
                      icon.highlight_color=0xfffab402         \
                      click_script="yabai -m space --focus 4"
