Message-ID: <3B0BF730.9D262F52@mvista.com>
Date: Wed, 23 May 2001 17:45:20 +0000
From: Scott Anderson <scott_anderson@mvista.com>
MIME-Version: 1.0
Subject: Re: vm_enough_memory() and RAM disks
References: <NFBBLKEIKLGDCJAAAEKOKEDPCAAA.cel@netapp.com>
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Chuck Lever <cel@netapp.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Chuck Lever wrote:
> 
> i've noticed a (possibly) related problem.
> 
> i've configured an NFS server to export a largish RAM disk for
> the purposes of testing NFS performance.  the RAM disk is half
> as large as the server's physical memory.  i've seen several
> times that when the machine runs out of memory (the "free"
> column in vmstat output goes below 1M) and the kernel wants
> to swap, the system freezes up.  my theory was that something
> was attempting to flush buffers, but because the buffers were
> bh_protected (because they were part of a large RAM disk), the
> kernel wasn't successful at making any normal headway, and so
> it looped.

I believe you are seeing the same problem.  I'm guessing that you're
on 2.2 because you didn't mention the Out Of Memory killer coming
into play.  If so, you can work around the problem by playing with
/proc/sys/vm/buffermem to increase the minimum amount of buffermem.
This has been removed from 2.4.

Of course, the real answer is to fix the code, but I must apologize
again that I haven't found the time to do that...

    Scott Anderson
    scott_anderson@mvista.com   MontaVista Software Inc.
    (408)328-9214               1237 East Arques Ave.
    http://www.mvista.com       Sunnyvale, CA  94085
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
