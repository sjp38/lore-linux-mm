Received: by alna.lt
	via sendmail from stdin
	id <m11T3b6-0002ehC@read-only.alna.lt> (Debian Smail3.2.0.102)
	for Linux-MM@kvack.org; Mon, 20 Sep 1999 15:35:12 +0200 (CEST)
Date: Mon, 20 Sep 1999 15:35:12 +0200
From: Kestutis Kupciunas <kesha@soften.ktu.lt>
Subject: oom - out of memory
Message-ID: <19990920153512.A20067@alna.lt>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM@kvack.org
List-ID: <linux-mm.kvack.org>

hello, linux memory managers,

thing i am eager to clarify is oom, out of memory problem,
which doesn't work as it is supposed to (at least i think it
doesn't do the trick). Having the system fully utilizing all the
memory available on box and requesting more simply "hangs"
the box. 
Going into more details: i have noticed this behavior
with all 2.[23].x kernels i have used (not sure about the previous series).
usually problem arises when manipulating LARGE sets of large images
under X (with gimp, imagemagick tools). as i open more images, naturally,
memory/swap usage grows, and when it grows to the bounds, keyboard stops
responding, screen stops repainting, hdd led's going crazy. all box
services stop responding - i'm unable to connect from remote box. *RESET* :(
this behavior isnt my box specific - i've vitnessed it happening on
a bunch of different intels as well. The only chracteristics that apply
to all those boxes are that all of them are x86.
but according to the oom() function, the pid which is requesting
memory when it's out, is beeing killed with a message.
i didnt find any message in logs later...
im not a 'kernel hacker', so maybe somebody could analyze the lifecycle
of linux-mm memory allocating up to the bounds and over?
or is there something i don't get right?
sorry for the messy english


regards,
ydum
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
