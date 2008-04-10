Date: Thu, 10 Apr 2008 19:39:51 +0200
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch 10/17] mm: fix bootmem alignment
Message-ID: <20080410173951.GA9482@wotan.suse.de>
References: <20080410170232.015351000@nick.local0.net> <20080410171101.395469000@nick.local0.net> <86802c440804101033p6e914cb4oacaeb6eca823d1cd@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <86802c440804101033p6e914cb4oacaeb6eca823d1cd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Yinghai Lu <yhlu.kernel@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, pj@sgi.com, kniht@linux.vnet.ibm.com
List-ID: <linux-mm.kvack.org>

On Thu, Apr 10, 2008 at 10:33:50AM -0700, Yinghai Lu wrote:
> On Thu, Apr 10, 2008 at 10:02 AM,  <npiggin@suse.de> wrote:
> > Without this fix bootmem can return unaligned addresses when the start of a
> >  node is not aligned to the align value. Needed for reliably allocating
> >  gigabyte pages.
> >
> >  I removed the offset variable because all tests should align themself correctly
> >  now. Slight drawback might be that the bootmem allocator will spend
> >  some more time skipping bits in the bitmap initially, but that shouldn't
> >  be a big issue.
> >
> 
> 
> this patch from Andi was obsoleted by the one in -mm

Ah, great thanks for letting me know.

 
 
> The patch titled
>     mm: offset align in alloc_bootmem
> has been added to the -mm tree.  Its filename is
>     mm-offset-align-in-alloc_bootmem.patch
> 
> ------------------------------------------------------
> Subject: mm: offset align in alloc_bootmem
> From: Yinghai Lu <yhlu.kernel.send@gmail.com>
> 
> Need offset alignment when node_boot_start's alignment is less than align
> required
> 
> Use local node_boot_start to match align.  so don't add extra opteration in
> search loop.
> 
> Signed-off-by: Yinghai Lu <yhlu.kernel@gmail.com>
> Cc: Andi Kleen <ak@suse.de>
> Cc: Yasunori Goto <y-goto@jp.fujitsu.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Ingo Molnar <mingo@elte.hu>
> Cc: Christoph Lameter <clameter@sgi.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
