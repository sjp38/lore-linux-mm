Date: Wed, 11 Oct 2000 07:38:08 -0400 (EDT)
From: Eric Lowe <elowe@myrile.madriver.k12.oh.us>
Subject: Re: 2.4.0test9 vm: disappointing streaming i/o under load
In-Reply-To: <Pine.LNX.4.21.0010110056230.7853-100000@ferret.lmh.ox.ac.uk>
Message-ID: <Pine.BSF.4.10.10010110734570.38557-100000@myrile.madriver.k12.oh.us>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chris Evans <chris@scary.beasts.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hello,

> Finally got round to checking out 2.4.0test9.
> 
> Unfortunately, 2.4.0test9 exhibits poor streaming i/o performance when
> under a bit of memory pressure.
> 
> The test is this: boot with mem=32M, log onto GNOME and start xmms playing
> a big .wav ripped from a CD (this requires 100-200k read i/o per second).
> 
> Then, I start then kill netscape. I then started a find / and started
> gnumeric firing up at the same time.

Would you try setting /proc/sys/vm/page-cluster to 8 or 16 and let
me know the results?  I think one _part_ of the problem is that
when the swapper isn't agressive enough, it causes too much disk
thrashing which gets in the way of normal I/O... my experience
has been that with modern disks with 512K+ cache you have to
write in 64K clusters to get optimum throughput.

Eric


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
