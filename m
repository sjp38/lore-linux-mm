Message-ID: <3CAD3632.E14560B@zip.com.au>
Date: Thu, 04 Apr 2002 21:29:22 -0800
From: Andrew Morton <akpm@zip.com.au>
MIME-Version: 1.0
Subject: Re: 2.2.20 suspends everything then recovers during heavy I/O
References: <4.2.0.58.20020404140237.00b6c390@london.rubylane.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jim Wilcoxson <jim@rubylane.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Jim Wilcoxson wrote:
> 
> I'm setting up a new system with 2.2.20, Ingo's raid patches, plus
> Hedrick's IDE patches.
> 
> When doing heavy I/O, like copying partitions between drives using tar in a
> pipeline, I've noticed that things will just stop for long periods of time,
> presumably while buffers are written out to the destination disk.  The
> destination drive light is on and the system is not exactly hung, because I
> can switch consoles and stuff, but a running vmstat totally suspends for
> 10-15 seconds.
> 
> Any tips or patches that will avoid this?  If our server hangs for 15
> seconds, we're going to have tons of web requests piled up for it when it
> decides to wakeup...
> 

Which filesystem are you using?

First thing to do is to ensure that your disks are achieving
the expected bandwidth.  Measure them with `hdparm -t'.
If the throughput is poor, and they're IDE, check the
chipset tuning options in your kernel config and/or
tune the disks with hdparm.

If all that fails, you can probably smooth things
out by tuning the writeback parameters in /proc/sys/vm/bdflush
(if that's there in 2.2.  It's certainly somewhere :))
Set the `interval' value smaller than the default five
seconds, set `nfract' higher.  Set `age_buffer' lower..

And finally: don't go copying entire partitions around
on a live web server :)

-
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
