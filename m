Received: from max.phys.uu.nl (max.phys.uu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id PAA19822
	for <linux-mm@kvack.org>; Sun, 5 Jul 1998 15:02:38 -0400
Date: Sun, 5 Jul 1998 21:00:18 +0200 (CEST)
From: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Reply-To: Rik van Riel <H.H.vanRiel@phys.uu.nl>
Subject: current VM performance
Message-ID: <Pine.LNX.3.96.980705205234.2186A-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Linux MM <linux-mm@kvack.org>
Cc: Linux Kernel <linux-kernel@vger.rutgers.edu>
List-ID: <linux-mm.kvack.org>

Hi,

While considering future VM improvements, I decided to do
some tests with the current VM subsystem.

I started with a 512x512 image (background of www.zip.com.au)
in GIMP. The first thing I did was increasing the image size
to 5120x5120, now I am 120M in swap on my 24M machine :-)

The resizing goes reasonably fast, a good indication that
swapOUT I/O clustering works. Zooming out to 16:0 (so that
I could view the entire image in one time) was hell though.
That was to be expected since we don't do swapIN clustering
yet...

Now the system is running the 'NL' enhancement filter, it's
happily churning away at 100 swapins a second, 50 swapouts
and 'some' filesystem activity... Gimp and the filter both
get around 25% CPU and x11amp doesn't skip a beat :-)

This looks quite acceptable to me, and together with swapin
readahead (yup, it's on it's way) even my 24M system should
rock again...

Rik.
+-------------------------------------------------------------------+
| Linux memory management tour guide.        H.H.vanRiel@phys.uu.nl |
| Scouting Vries cubscout leader.      http://www.phys.uu.nl/~riel/ |
+-------------------------------------------------------------------+

--
This is a majordomo managed list.  To unsubscribe, send a message with
the body 'unsubscribe linux-mm me@address' to: majordomo@kvack.org
