From: Michal Ostrowski <mostrows@styx.uwaterloo.ca>
MIME-Version: 1.0
Content-Type: multipart/mixed; boundary="0pW+cVWAQn"
Content-Transfer-Encoding: 7bit
Message-ID: <14646.18070.554583.303619@styx.uwaterloo.ca>
Date: Thu, 1 Jun 2000 07:18:46 -0400 (EDT)
Subject: Poor I/O Performance (test program attached)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

--0pW+cVWAQn
Content-Type: text/plain; charset=us-ascii
Content-Description: message body text
Content-Transfer-Encoding: 7bit


It was suggested to me to post the program with which I did my
testing. And so, by popular demand, the code is attached.

You can compile the code using: "gcc -o vmtest vmtest.c"

The command line options are described within the comments at the top
of the source file.  

I ran my tests with:

dd if=/dev/zero of=bigfile count=250000 bs=4096
time vmtest file bigfile threads 10 itr 1000 blocks 32 size 1000000000
(repeat last line, altering parameters as necessary)

Michal Ostrowski
mostrows@styx.uwaterloo.ca


--0pW+cVWAQn
Content-Type: application/octet-stream
Content-Disposition: attachment;
	filename="vmtest.c.gz"
Content-Transfer-Encoding: base64

H4sIAAhENjkAA61We08bRxD/2/4UI1ekZ3O2IYoiNbaRELgtEgEEJG1FkXXc7dlb7m5Pt3tQ
kvDdOzO797ABpYlyEmZ3dvY3j53XePCjvi4M4C41QhsYDnEFYzgan4I2hdAa8kItiyAlpjNR
xKpINRQiiEDlogiMVJmGwEARZJFKIVcyMxpkBgHEMhEjune5EoWAAP96WZnSZd17gpFbcBHR
ZaNMkPBdumFW7o5bMFSpkdWo6h6eCS0YVfPFeRCuNoTYU8In1JtEhbcIav/THacr9LT8JHqQ
B2i3MKIAqSETVpzORSjjBzYOiA9QOu80Xb9nU3vaBKYHkRI6+9nASiQ5eGK0HKGb7iGS+lb3
iZv+PuhgKd7Ryn3uKaYsgX4y1GIPrirjG4dcw5U0BVQ+vUaQTgeurEFQm4hsVlFSEhfXYG3t
dPDnB33jbvcnmYVJGQmYlpnUJhqt9lo0Ha7EJslEUhGpTXvQY3LeM2TzkAu9gdDibqhxmJlk
nSSKIlNPpCfy5jk5MhVPxaRpkG0CFDJbEg1D3kbswjp8tjNhGu8W7PsZOJo0VcTb/SdRqDiy
a/qPqGWIcKjEXZCAyCJaPqGj1YWxJ7UkjVLeTLpMuFfFrSi8OyUjjKygWPY/dym48GwAN2WM
rGhR7u349uqg0dU/Oz+9XJzP9w+/8OqP86PLuf9+/2xxdn70cR/XXYwy+qzu/k4fhTpwUHGs
hZnUe1Qkanb4DqpotgVx8i5HX5rY612QXehW2JKwlf+d9XwPD/pogI9aV4LuVxjKXuPKvR00
r9shSF2mk27HaoFG2rLk9WFr7YWQpeDznDLHQyMQ3W98YN2hfYvTcg5q0JGxR5enQFI7be0Z
zRr5DrY0qU9VlPYeh2Cf7j+iquMBHCqskahuyjb48E+JWU/FBCsZ6OBWoC+xhJAztEoFHJx9
YGn0tIDFjNiiwAQjOFFG4Bar8L0ts6QG3vMhU4bfOacd3zarUhObXqkyiag6xUGZmAoQ3RBj
wcN87qAqHr0exS5M+CGn3hMXjWmtYn6l/gS2t4mv8gtatz1DyCsiXjvTh8N2DhDbI//yz1Jw
VGNYBQ/eKxf9/smH4+M6yGLPkUfmboFdIJzWyVBRSP4G0/Zsd4e/CWnQOsSzthbVU0YqExiE
HIEbUMOn8rYd+MBbR15nJc6+FSb+lcarE6f7aLM2DWRGnqSEDX0IV0Ex4Oy9a9K3boKc7BUx
Ejfl0laZihTTw6+TqFuQHyyF4LE4UFuY9caRuBvrKOhtZCc/o609VGn5B1+0hTlrCbC1zhFs
eUANsAFnnpVAtJ5/ujg/PD05/ms9n8novd0+Uz5zmqHgMM3xMci6nk+OuCKu4evr/mxWpx8f
zwKjpNew7F5TrtHxcEgEij6R4IjQwnUjwIvArpx/B3I1srwI7Ri+B5se7GVgHhtm0Ib8KiLG
xcuATbYS7Lery8PUi+iuO/4PXGg+SmFLbpUP/m3ijfzQDjRXO5DBFe7c1uVnCnSdnBvFybaM
mFKAWsYrlwuOsZKAXNNvF0AOQ1c4zzivOAEjbbjktvnb3Yw46cK4feEmuW3urE0izzHVSUd5
v56ytoWuJW2nzLRcZjyrY9LjaMwNFTtpgV7Bre+6QpuPLdeE5hFLbb0TzT3xzc4vb+HmAdsZ
KkmWaexHMhTckFy94pNmfvFcJg13+wO6/uz4YpfzP+cHNLxwYLUHmtYg00EdScD2DMFe4369
I9X1vOpJ3CaxPcppSxGgRig3p4ODRGV2tKGuIqsI56gK8Ux4dmrzWQH/4Pj0ZL74+P6LXfx6
US2OjufV+uLot9/3Tw59HvQG/RpzfUTptDUQX51P7LPY7Kxd8Za7t3sxV7XtjNmS/dj9D04l
VD2WDgAA

--0pW+cVWAQn--
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
