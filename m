Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id UAA16959
	for <linux-mm@kvack.org>; Mon, 22 Dec 1997 20:05:03 -0500
Date: Mon, 22 Dec 1997 23:14:33 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Reply-To: H.H.vanRiel@fys.ruu.nl
Subject: Re: mmap-age patch, comments wanted 
In-Reply-To: <m0xkBUW-000sMBC@linux.biostat.hfh.edu>
Message-ID: <Pine.LNX.3.91.971222230403.15190B-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Noel Maddy <ncm@biostat.hfh.edu>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 22 Dec 1997, Noel Maddy wrote:

> That was definitely the case with your older vhand patches -- with 
> them, I could get about 20M more into virtual memory before 
> performance started degrading.  What I'm seeing now is a change in 
> performance at the same load level.  I'm not sure whether the overall 
> performance is hurt, because the vanilla kernel thrashes a lot in the 
> same situation, but the system remains responsive.  It could be that 
> the load takes longer in the vanilla kernel (I'll try to check that 
> today), but the lack of responsiveness with the mmap-age patch makes 
> it *seem* slower.  

With vhand, the kernel didn't properly age user-pages, so
swap usage was overly high compared to vanilla or mmap-age,
so comparing swap usage is no good indication of system load.

Also, between vanilla and mmap-age, the mmap-age patched kernel
uses swap more than the vanilla one. But the difference should
be very small, so swap usage should still be usable as an
indication for VM load.

I think that what's really making things slower, is that kswapd
now has to scan more pages before it can swap one out. This
makes the swapout slower (as MAX_SWAP_FAIL still is set at 3)
so there are less free pages left to swap things in again.
I'm going to try to resolve this issue right now...

Rik.
+-----------------------------+------------------------------+
| For Linux mm-patches, go to | "I'm busy managing memory.." |
| my homepage (via LinuxHQ).  | H.H.vanRiel@fys.ruu.nl       |
| ...submissions welcome...   | http://www.fys.ruu.nl/~riel/ |
+-----------------------------+------------------------------+
