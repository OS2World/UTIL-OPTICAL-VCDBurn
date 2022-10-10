Burn (S)VCD video for eCS and OS/2 V 0.9.5.6
============================================

This program is freeware and it is published under the GNU General Public License.
Details see in copying.txt.

Disclaimer
~~~~~~~~~~
You are using this program at your own risk. The the author gives no
warranty for the function or any others things affected by this program.
Under no circumstances the author is liable for any loss or damage supposed
to derive from the use of the program.

What is it ?
~~~~~~~~~~~~
It is a GUI to do the following things:
- encode video material
- create VCD or SVCD image file
- burn the image on CD

It's a GUI, that means the work do commandline (VIO) programs.
You need the follwing programs:
- ffmpeg
- vcdimager
- cdrdao

The most recent versions of ffmpeg and vcdimager you find on:
http://smedley.info/os2ports

ATTENTION: ffmpeg beginning with version of 2006/11/21 uses the video bitrate in
Bit/s. For giving in kBit/s a "k" must be append after the value, DVDBurn does
this beginning with this version self-employed (the only one change in V 0.9.5.6).

cdrdao can be loaded from hobbes server. In the moment the following link is actual:
http://hobbes.nmsu.edu/pub/os2/apps/mmedia/cd/cd-r/cdrdao2-1.2.1.zip

Some of the programs need special dlls, please look in the readme
files.

How to use it
~~~~~~~~~~~~~
To get the program VCDBurn.exe running the file VROBJ.DLL must be present, normally
eCS and OS/2 users have already this file. If not you can download it here:
http://bohn-stralsund.de/downloae.htm

First you must click on "settings" and set the paths of the commandline applications.
For each commandline program the settings are on a separate tab register.
Important for burning is the device id of your recording device (eg. 0,1,0) and the driver
on the "cdrdao" tab.
A folder for the target files must be set on tab "common".

For transcoding the ffmpeg bitrates for video and audio have to be set.
For VCD these ar defined fix by the standard (video=1150 kBps, audio=224 KBps). For the two
others I suggest the following values:
SVCD: video=2500 kBps, audio=224 kBps
XVCD: video=1800 kBps, audio=224 kBps

In the main window the desired actions must be checked. With the "+" button
are files selected to encode. As type of the video CD may be choosed SVCD,VCD
(fixed bitrate 1150 kB/s) or XVCD (VCD with adjustable bitrate).

With click on "Start" button the checked actions are executed.

For further information look at my website "http://bohn-stralsund.de", choose english
or german language and then click on "VCDBurn" in the navigation on the left.


History
~~~~~~~
V 0.9.5.6
- Adaption to ffmpeg versions from 2006/11/21 or newer

V 0.9.5.5
- Correct display of free harddisk space also on JFS partitions
- Check of "MV errors" for ffmpeg

V 0.9.5.3
- Display free space on target drive

V 0.9.5.2
- Error in filesize calculation fixed

V 0.9.5.1
- parsing error fixed for using generic-mmc-raw driver of cdrdao
- fonts for filelist, short log and logfile window can be set with font from system font palette

V 0.9.5.0
- bitrate for video and audio can now separat be set for SVCD and XVCD
- encoded films (for example ripped from SVCD) now can be transcoded, in the log window
  a comment is shown if a file already is encoded
- the program now recognises the path of the sourcefiles
- error fixed for 2 pass encoding (2. pass did not work for XVCD)
- the logwindow now can be cleared and the contents of the logfile can be shown

V 0.9.4.0
- first version, development status corresponds to same version of DVDBurn
