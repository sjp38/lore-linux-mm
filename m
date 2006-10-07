Received: from midway.site ([71.117.236.95]) by xenotime.net for <linux-mm@kvack.org>; Sat, 7 Oct 2006 10:57:31 -0700
Date: Sat, 7 Oct 2006 10:58:59 -0700
From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: mm section mismatches
Message-Id: <20061007105859.70e2f44d.rdunlap@xenotime.net>
In-Reply-To: <20061006234609.641f42f4.akpm@osdl.org>
References: <20061006184930.855d0f0b.akpm@google.com>
	<20061006211005.56d412f1.rdunlap@xenotime.net>
	<20061006234609.641f42f4.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, Pekka Enberg <penberg@cs.helsinki.fi>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

On Fri, 6 Oct 2006 23:46:09 -0700 Andrew Morton wrote:

> On Fri, 6 Oct 2006 21:10:05 -0700
> Randy Dunlap <rdunlap@xenotime.net> wrote:
> 
> > On Fri, 6 Oct 2006 18:49:30 -0700 Andrew Morton wrote:
> > 
> > > i386 allmoconfig, -mm tree:
> 
> <looks>
> 
> > > WARNING: vmlinux - Section mismatch: reference to .init.data:arch_zone_highest_possible_pfn from .text between 'memmap_zone_idx' (at offset 0xc0155e3b) and 'calculate_totalreserve_pages'
> 
> This one is non-init memmap_zone_idx() referring to __initdata
> arch_zone_highest_possible_pfn (Hi, Mel).

Yep.
I don't see any users (callers) of memmap_zone_idx()...
Maybe that's why I still cannot reproduce the problem.

> > > WARNING: vmlinux - Section mismatch: reference to .init.data:initkmem_list3 from .text between 'set_up_list3s' (at offset 0xc016ba8e) and 'kmem_flagcheck'
> 
> This is non-init set_up_list3s() referring to __initdata initkmem_list3[]
> (Hi, Pekka and Christoph!)

I can't repro that one either, so I'll let one of (...) fix it.

> > > any takers?
> > 
> > Could be.  what patchset?  I don't see this in 2.6.18-mm3.
> > 
> 
> Both bugs are in mainline.

---
~Randy

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
