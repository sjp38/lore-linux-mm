Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 1C8346B0027
	for <linux-mm@kvack.org>; Fri,  5 Apr 2013 04:08:19 -0400 (EDT)
Date: Fri, 5 Apr 2013 17:08:17 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [LSF/MM TOPIC]swap improvements for fast SSD
Message-ID: <20130405080817.GC32126@blaptop>
References: <20130122065341.GA1850@kernel.org>
 <20130123075808.GH2723@blaptop>
 <515E17FC.9050008@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <515E17FC.9050008@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Simon Jeons <simon.jeons@gmail.com>
Cc: Shaohua Li <shli@kernel.org>, lsf-pc@lists.linux-foundation.org, linux-mm@kvack.org, Rik van Riel <riel@redhat.com>

On Fri, Apr 05, 2013 at 08:17:00AM +0800, Simon Jeons wrote:
> Hi Minchan,
> On 01/23/2013 03:58 PM, Minchan Kim wrote:
> >On Tue, Jan 22, 2013 at 02:53:41PM +0800, Shaohua Li wrote:
> >>Hi,
> >>
> >>Because of high density, low power and low price, flash storage (SSD) is a good
> >>candidate to partially replace DRAM. A quick answer for this is using SSD as
> >>swap. But Linux swap is designed for slow hard disk storage. There are a lot of
> >>challenges to efficiently use SSD for swap:
> >Many of below item could be applied in in-memory swap like zram, zcache.
> >
> >>1. Lock contentions (swap_lock, anon_vma mutex, swap address space lock)
> >>2. TLB flush overhead. To reclaim one page, we need at least 2 TLB flush. This
> >>overhead is very high even in a normal 2-socket machine.
> >>3. Better swap IO pattern. Both direct and kswapd page reclaim can do swap,
> >>which makes swap IO pattern is interleave. Block layer isn't always efficient
> >>to do request merge. Such IO pattern also makes swap prefetch hard.
> >Agreed.
> >
> >>4. Swap map scan overhead. Swap in-memory map scan scans an array, which is
> >>very inefficient, especially if swap storage is fast.
> >Agreed.
> >
> >>5. SSD related optimization, mainly discard support
> >>6. Better swap prefetch algorithm. Besides item 3, sequentially accessed pages
> >>aren't always in LRU list adjacently, so page reclaim will not swap such pages
> >>in adjacent storage sectors. This makes swap prefetch hard.
> >One of problem is LRU churning and I wanted to try to fix it.
> >http://marc.info/?l=linux-mm&m=130978831028952&w=4
> 
> I'm interested in this feature, why it didn't merged? what's the
> fatal issue in your patchset?
> http://lwn.net/Articles/449866/

There wasn't any fatal issue, AFAIRC but some people had a concern about
balancing between code complexity and benefit and dragged for a long time
and I lost interest.

> You mentioned test script and all-at-once patch, but I can't get
> them from the URL, could you tell me how to get it?

You can google it and google will find it in a few second.

http://www.filewatcher.com/b/ftp/ftp.cs.huji.ac.il/mirror/linux/kernel/linux/kernel/people/minchan/inorder_putback/v4-0.html

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
