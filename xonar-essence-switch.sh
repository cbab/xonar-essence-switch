#!/bin/sh
# Copyright (c) 2014 Christian Babeux <christian.babeux@0x80.ca>
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# Volume switching script for Xonar Essence STX.

# Soundcard number
# Can be obtained with: `cat /proc/asound/cards`
SND_NUM=0

# Default volumes levels when switching.
SPKR_VOL=250
HP_VOL=188

# Name of master vol. and analog out. controls as shown by
# `amixer controls`
VOL_NAME="Master Playback Volume"
OUT_NAME="Analog Output"

# Analog out. item name.
# `amixer cget name="Analog Output"`
# numid=15,iface=MIXER,name='Analog Output'
#   ; type=ENUMERATED,access=rw------,values=1,items=3
#   ; Item #0 'Speakers'
#   ; Item #1 'Headphones'
#   ; Item #2 'FP Headphones'
#   : values=0

SPKR_ID=0
HP_ID=1

CURRENT_OUT=`amixer -c ${SND_NUM} cget name='Analog Output' | grep ": values=" | cut -d '=' -f2`

if [ "${CURRENT_OUT}" == "${SPKR_ID}" ] ; then
    echo "On speakers, switching to headphones."
    # Lower the volume first to avoid headphones damage!
    amixer -q -c ${SND_NUM} cset name="${VOL_NAME}" ${HP_VOL} $1
    # Switch the output.
    amixer -q -c ${SND_NUM} cset name="${OUT_NAME}" ${HP_ID} $1
else
    if [ "${CURRENT_OUT}" == "${HP_ID}" ] ; then
        echo "On headphone, switching to speakers."
        # Switch first to avoid volume spike.
        amixer -q -c ${SND_NUM} cset name="${OUT_NAME}" ${SPKR_ID} $1
        amixer -q -c ${SND_NUM} cset name="${VOL_NAME}" ${SPKR_VOL} $1
    else
        echo "Error, unknown analog output."
    fi
fi
