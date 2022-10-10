#!/usr/bin/env sh

sketchybar --add       item               calendar.time right                           \
           --set       calendar.time      update_freq=15                                \
                                          icon.drawing=off                              \
                                          script="$PLUGIN_DIR/time.sh"                  \
                                                                                        \
           --clone     calendar.date      label_template                                \
           --set       calendar.date      update_freq=60                                \
                                          position=right                                \
                                          label=cal                                     \
                                          drawing=on                                    \
                                          background.padding_right=0                    \
                                          script="$PLUGIN_DIR/date.sh"                  \
                                                                                        \
           --add       bracket            calendar                                      \
                                          calendar.date                                 \
                                                                                        \
           --set       calendar           background.drawing=on
