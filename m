Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx104.postini.com [74.125.245.104])
	by kanga.kvack.org (Postfix) with SMTP id 265036B0191
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 10:40:19 -0500 (EST)
Date: Mon, 12 Dec 2011 15:40:15 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 04/11] mm: compaction: export some of the functions
Message-ID: <20111212154015.GI3277@csn.ul.ie>
References: <1321634598-16859-1-git-send-email-m.szyprowski@samsung.com>
 <1321634598-16859-5-git-send-email-m.szyprowski@samsung.com>
 <20111212142906.GE3277@csn.ul.ie>
 <op.v6dseqji3l0zgt@mpn-glaptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <op.v6dseqji3l0zgt@mpn-glaptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Marek Szyprowski <m.szyprowski@samsung.com>, linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-media@vger.kernel.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, Kyungmin Park <kyungmin.park@samsung.com>, Russell King <linux@arm.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Ankita Garg <ankita@in.ibm.com>, Daniel Walker <dwalker@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Jesse Barker <jesse.barker@linaro.org>, Jonathan Corbet <corbet@lwn.net>, Shariq Hasnain <shariq.hasnain@linaro.org>, Chunsang Jeong <chunsang.jeong@linaro.org>, Dave Hansen <dave@linux.vnet.ibm.com>

On Mon, Dec 12, 2011 at 03:41:04PM +0100, Michal Nazarewicz wrote:
> On Mon, 12 Dec 2011 15:29:07 +0100, Mel Gorman <mel@csn.ul.ie> wrote:
> 
> >On Fri, Nov 18, 2011 at 05:43:11PM +0100, Marek Szyprowski wrote:
> >>From: Michal Nazarewicz <mina86@mina86.com>
> >>
> >>This commit exports some of the functions from compaction.c file
> >>outside of it adding their declaration into internal.h header
> >>file so that other mm related code can use them.
> >>
> >>This forced compaction.c to always be compiled (as opposed to being
> >>compiled only if CONFIG_COMPACTION is defined) but as to avoid
> >>introducing code that user did not ask for, part of the compaction.c
> >>is now wrapped in on #ifdef.
> >>
> >>Signed-off-by: Michal Nazarewicz <mina86@mina86.com>
> >>Signed-off-by: Marek Szyprowski <m.szyprowski@samsung.com>
> >>---
> >> mm/Makefile     |    3 +-
> >> mm/compaction.c |  112 +++++++++++++++++++++++--------------------------------
> >> mm/internal.h   |   35 +++++++++++++++++
> >> 3 files changed, 83 insertions(+), 67 deletions(-)
> >>
> >>diff --git a/mm/Makefile b/mm/Makefile
> >>index 50ec00e..24ed801 100644
> >>--- a/mm/Makefile
> >>+++ b/mm/Makefile
> >>@@ -13,7 +13,7 @@ obj-y			:= filemap.o mempool.o oom_kill.o fadvise.o \
> >> 			   readahead.o swap.o truncate.o vmscan.o shmem.o \
> >> 			   prio_tree.o util.o mmzone.o vmstat.o backing-dev.o \
> >> 			   page_isolation.o mm_init.o mmu_context.o percpu.o \
> >>-			   $(mmu-y)
> >>+			   $(mmu-y) compaction.o
> >
> >That should be
> >
> >compaction.o $(mmu-y)
> >
> >for consistency.
> >
> >Overall, this patch implies that CMA is always compiled in.
> 
> Not really.  But yes, it produces some bloat when neither CMA nor
> compaction are compiled.  I assume that linker will be able to deal
> with that (since the functions are not EXPORT_SYMBOL'ed).
> 

The bloat exists either way. I don't believe the linker strips it out so
overall it would make more sense to depend on compaction to keep the
vmstat counters for debugging reasons if nothing else. It's not
something I feel very strongly about though.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
