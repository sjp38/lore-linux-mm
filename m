Received: from max.fys.ruu.nl (max.fys.ruu.nl [131.211.32.73])
	by kvack.org (8.8.7/8.8.7) with ESMTP id IAA26874
	for <linux-mm@kvack.org>; Thu, 27 Nov 1997 08:38:11 -0500
Date: Thu, 27 Nov 1997 14:24:19 +0100 (MET)
From: Rik van Riel <H.H.vanRiel@fys.ruu.nl>
Subject: Re: Linux memory management wish :-)
In-Reply-To: <m0xajZy-0002feC@pcape1.pi.infn.it>
Message-ID: <Pine.LNX.3.91.971127142009.259G-100000@mirkwood.dummy.home>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrea Cisternino <acister@pcape1.pi.infn.it>
Cc: linux-mm <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Wed, 26 Nov 1997, Andrea Cisternino wrote:

> Hi Rik,
> 
> > Send Linux memory-management wishes to me: I'm currently looking
> > for something to hack...
> 
> OK, here I go...
> 
> I'm a researcher at the italian National Institute of Nuclear Physics 
> (INFN) and I'm currently developing Linux device drivers for one of our 
> projects (you can find more info in http://pcape1.pi.infn.it/~acister/dev).
> 
> The hardware/software combination I have to deal with needs big contiguous 
> memory buffers for DMA operations from/to the PCI bus.
> 
> To get such buffers I'm presently using the bigphysarea patch from Matt 
> Welch to reserve a memory pool at boot time but I would really like to see 
> some "standard" kernel support for this kind of memory allocation.

We could 'reserve' a large amount of memory for use by
DMA/buffer/cache only, so when you need a large amount
of memory, the system can kick out buffermem and cache-
mem on request...
Also, the memory in that area can't be allowed to have
lots of dirty pages in it.  Kflushd will have to check 
it every xx jiffies.
On a 128M machine, reserving 16MB for buffer/cache mem
isn't that bad.

I'll look into this (after my crashing HD is replaced
by a new one... I can't risk losing even more data).

grtz,

Rik.

----------
Send Linux memory-management wishes to me: I'm currently looking
for something to hack...
