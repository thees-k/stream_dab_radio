# simple_stream_dab_radio.sh

A simple script to stream DAB radio using Icecast2, DarkIce, Screen and Welle-cli.

## Installation

### 1. Install Icecast2

Install Icecast2 by running the following command:

```bash
sudo apt-get install icecast2
```

The configuration file is located at `/etc/icecast2/icecast.xml`. For a basic configuration, leave everything unchanged except for the `<hostname>localhost</hostname>` line. Replace "localhost" with your computer's hostname or its IP address, for example `<hostname>mygreatcomputer</hostname>` or
`<hostname>192.168.178.2</hostname>`.


### 2. Install Darkice

Install Darkice by running the following command:

```bash
sudo apt-get install darkice
```

Warning: Do not install darkice version 1.4 as it may lead to errors like: "DarkIce: AudioSource.cpp:135: trying to open ALSA DSP device without support compiled hw
,1,0 [0]".

### 3. Install Loopback Sound Card

Add the following line to the file `/etc/modules`:

```
snd-aloop
```

Then reboot your system.

### 4. Install Screen

Install screen by running the following command:

```bash
sudo apt-get install screen
```

### 5. Install Welle-cli

Install welle-cli by running the following command:

```bash
sudo apt-get install welle-cli
```


## Configuration

Below is an example of a `darkice.cfg` configuration file.  Make sure to replace `YOUR_HOSTNAME` with your computer's hostname or IP address in the server line. Also, adjust the localDumpFile line to point to a valid directory on your system.

```
[general]
duration        = 0         # Duration of encoding in seconds. 0 for endless.
bufferSecs      = 5         # Size of internal buffer in seconds.
reconnect       = yes       # Reconnect on connection loss.

[input]
device          = hw:Loopback,1,0
sampleRate      = 44100     # Sample rate in Hz. Common values: 11025, 22050, 44100, 48000
bitsPerSample   = 16        # Bits per sample
channel         = 2         # Channels. 1 = mono, 2 = stereo

[icecast2-0]
bitrateMode     = vbr       # cbr, abr, vbr
quality         = 1.0       # use only with vorbis(?)-vbr: 0.1-1.0 (1.0 is best)
format          = mp3       # Stream format: mp3, vorbis
lowpass         = 16400     # for radio transmissions => "Using polyphase lowpass filter, transition band: 16538 Hz - 17071 Hz"

server          = YOUR_HOSTNAME   # Hostname or IP address of the Icecast server
port            = 8000       # Port of the Icecast server, usually 8000
password        = hackme     # Password for the source user on the Icecast server
mountPoint      = stream     # Mount point of the stream on the server
name            = piradio    # Metadata: Name of the radio station
description     = VBR-MP3!   # Metadata: Description of the radio station
url             = http://... # URL of the radio station
genre           = Classical  # Metadata: Genre of the radio station
public          = no         # Publication of metadata of the radio station

localDumpFile   = /home/USERNAME/Recordings/dump.mp3
fileAddDate     = yes
fileDateFormat  = _%Y-%m-%d_%H-%M-%S
```

## Usage

Make the script executable:

```bash
chmod +x simple_stream_dab_radio.sh
```

Run the script with the required parameters:

```bash
sudo ./simple_stream_dab_radio.sh -c DARKICE_CONFIG -h CHANNEL -s STATION_NAME
```

Parameters

    -c DARKICE_CONFIG: Path to the DarkIce configuration file.
    -h CHANNEL: DAB channel to stream.
    -s STATION_NAME: Name of the radio station.

### Example

```bash
sudo ./simple_stream_dab_radio.sh -c ./Configuration/darkice.cfg -h 6C -s "NDR Kultur"
```

You will see the following output:
```
icecast2 started.
darkice started.
DarkIce 1.3 live audio streamer, http://code.google.com/p/darkice/
Copyright (c) 2000-2007, Tyrell Hungary, http://tyrell.hu/
Copyright (c) 2008-2013, Akos Maroy and Rafael Diniz
This is free software, and you are welcome to redistribute it 
under the terms of The GNU General Public License version 3 or
any later version.

Using config file: ./Configuration/darkice.cfg
06-Jul-2024 12:52:38 Using ALSA DSP input device: hw:Loopback,1,0
06-Jul-2024 12:52:38 buffer size:  882000
06-Jul-2024 12:52:38 encoding
06-Jul-2024 12:52:38 scheduler high priority 99
06-Jul-2024 12:52:38 Using POSIX real-time scheduling, priority 4
06-Jul-2024 12:52:38 HTTP/1.0 200
06-Jul-2024 12:52:38 set lame mode 1
06-Jul-2024 12:52:38 set lame channels 2
06-Jul-2024 12:52:38 set lame in sample rate 44100
06-Jul-2024 12:52:38 set lame out sample rate 44100
06-Jul-2024 12:52:38 set lame vbr bitrate 4
06-Jul-2024 12:52:38 set lame vbr quality 0
06-Jul-2024 12:52:38 set lame lowpass frequency 16400
06-Jul-2024 12:52:38 set lame highpass frequency 0
06-Jul-2024 12:52:38 set lame psycho acoustic model 1
06-Jul-2024 12:52:38 set lame error protection 1
LAME 3.100 64bits (http://lame.sf.net)
Using polyphase lowpass filter, transition band: 16538 Hz - 17071 Hz
06-Jul-2024 12:52:38 MultiThreadedConnector :: transfer, bytes 0
06-Jul-2024 12:52:38 MultiThreadedConnector :: ThreadData :: threadFunction, was (thread, priority, type):  0x55a9a81280 4 SCHED_FIFO
06-Jul-2024 12:52:38 MultiThreadedConnector :: ThreadData :: threadFunction, now is (thread, priority, type):  0x55a9a81280 1 SCHED_FIFO
welle-cli ("NDR Kultur" @ 6C) started.

-> Press CTRL+C to stop/exit!!

```

&rarr; With the given  `darkice.cfg` configuration file you will be able to receive your DAB radio station as MP3 internet radio on URL: `http://YOUR_HOSTNAME:8000/stream`

&rarr; To stop the streaming you must press CTRL+C.

Have fun with the script!



