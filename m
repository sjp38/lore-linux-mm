Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id DF7D16B0088
	for <linux-mm@kvack.org>; Fri,  7 Jan 2011 07:51:41 -0500 (EST)
Date: Fri, 7 Jan 2011 13:51:35 +0100
From: Ingo Molnar <mingo@elte.hu>
Subject: Re: Very large memory configurations:   > 16 TB
Message-ID: <20110107125135.GD20761@elte.hu>
References: <20110106170942.GA8253@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110106170942.GA8253@sgi.com>
Sender: owner-linux-mm@kvack.org
To: Jack Steiner <steiner@sgi.com>
Cc: linux-mm@kvack.org, linux-ia64@vger.kernel.org
List-ID: <linux-mm.kvack.org>


* Jack Steiner <steiner@sgi.com> wrote:

> SGI is currently developing an x86_64 system with more than 16TB of memory per 
> SSI. As far as I can tell, this should be supported. The relevant definitions such 
> as MAX_PHYSMEM_BITS appear ok.
> 
> 
> One area of concern is page counts. Exceeding 16TB will also exceed MAX_INT page 
> frames. The kernel (at least in all places I've found) keep pagecounts in longs.
> 
> Have I missed anything? Should this > 16TB work? Are there any kernel problems or 
> problems with user tools that anyone knows of.
> 
> Any help or pointers to potential problem areas would be appreciated...

See this older 2008 mail i wrote about our current x86 64-bit limits:

  http://lkml.indiana.edu/hypermail/linux/kernel/0812.2/00292.html

In that mail i outlined the various limits and the methods that it would take to 
increase those limits, in order of difficulty. It appears we can probably go up to 
32 TB relatively easily and up to 64 TB realistically - 128 TB theoretically.

Note that obviously there can be a number of unknown problems rise up, so you should 
try to simulate a ton of RAM ASAP, before building the hardware ;-) (We could even 
try to add a "memory size debug" feature to the kernel which would inject huge 
'fake' blocks of RAM that the kernel will pretend to have but will skip in the buddy 
allocator or so.

Beyond 64 TB it probably gets painful, very painful - a hardware extension to the 
pagetable and canonical virtual memory space is the pragmatic solution there.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
