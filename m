Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CDDAA6B004A
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 04:59:42 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o828xdnu000710
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Thu, 2 Sep 2010 17:59:39 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 6737945DE53
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 17:59:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 41C6245DE51
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 17:59:39 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 096791DB8042
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 17:59:39 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.249.87.106])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 8BAB51DB8045
	for <linux-mm@kvack.org>; Thu,  2 Sep 2010 17:59:38 +0900 (JST)
Date: Thu, 2 Sep 2010 17:54:24 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100902175424.5849c197.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
References: <cover.1282286941.git.m.nazarewicz@samsung.com>
	<1282310110.2605.976.camel@laptop>
	<20100825155814.25c783c7.akpm@linux-foundation.org>
	<20100826095857.5b821d7f.kamezawa.hiroyu@jp.fujitsu.com>
	<op.vh0wektv7p4s8u@localhost>
	<20100826115017.04f6f707.kamezawa.hiroyu@jp.fujitsu.com>
	<20100826124434.6089630d.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTi=T1y+sQuqVTYgOkYvqrxdYB1bZmCpKafN5jPqi@mail.gmail.com>
	<20100826133028.39d731da.kamezawa.hiroyu@jp.fujitsu.com>
	<AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
	<20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Minchan Kim <minchan.kim@gmail.com>, =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Fri, 27 Aug 2010 17:16:39 +0900
KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:

> On Thu, 26 Aug 2010 18:36:24 +0900
> Minchan Kim <minchan.kim@gmail.com> wrote:
> 
> > On Thu, Aug 26, 2010 at 1:30 PM, KAMEZAWA Hiroyuki
> > <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > > On Thu, 26 Aug 2010 13:06:28 +0900
> > > Minchan Kim <minchan.kim@gmail.com> wrote:
> > >
> > >> On Thu, Aug 26, 2010 at 12:44 PM, KAMEZAWA Hiroyuki
> > >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >> > On Thu, 26 Aug 2010 11:50:17 +0900
> > >> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > >> >
> > >> >> 128MB...too big ? But it's depend on config.
> > >> >>
> > >> >> IBM's ppc guys used 16MB section, and recently, a new interface to shrink
> > >> >> the number of /sys files are added, maybe usable.
> > >> >>
> > >> >> Something good with this approach will be you can create "cma" memory
> > >> >> before installing driver.
> > >> >>
> > >> >> But yes, complicated and need some works.
> > >> >>
> > >> > Ah, I need to clarify what I want to say.
> > >> >
> > >> > With compaction, it's helpful, but you can't get contiguous memory larger
> > >> > than MAX_ORDER, I think. To get memory larger than MAX_ORDER on demand,
> > >> > memory hot-plug code has almost all necessary things.
> > >>
> > >> True. Doesn't patch's idea of Christoph helps this ?
> > >> http://lwn.net/Articles/200699/
> > >>
> > >
> > > yes, I think so. But, IIRC, A it's own purpose of Chirstoph's work is
> > > for removing zones. please be careful what's really necessary.
> > 
> > Ahh. Sorry for missing point.
> > You're right. The patch can't help our problem.
> > 
> > How about changing following this?
> > The thing is MAX_ORDER is static. But we want to avoid too big
> > MAX_ORDER of whole zones to support devices which requires big
> > allocation chunk.
> > So let's add MAX_ORDER into each zone and then, each zone can have
> > different max order.
> > For example, while DMA[32], NORMAL, HIGHMEM can have normal size 11,
> > MOVABLE zone could have a 15.
> > 
> > This approach has a big side effect?
> > 
> 
> Hm...need to check hard coded MAX_ORDER usages...I don't think
> side-effect is big. Hmm. But I think enlarging MAX_ORDER isn't an
> important thing. A code which strips contiguous chunks of pages from
> buddy allocator is a necessaty thing, as..
> 
> What I can think of at 1st is...
> ==
> 	int steal_pages(unsigned long start_pfn, unsigned long end_pfn)
> 	{
> 		/* Be careful mutal execution with memory hotplug, because reusing code */
> 
> 		split [start_pfn, end_pfn) to pageblock_order
> 		
> 		for each pageblock in the range {
> 			Mark this block as MIGRATE_ISOLATE
> 			try-to-free pages in the range or
> 			migrate pages in the range to somewhere.
> 			/* Here all pages in the range are on buddy allocator
> 			and free and never be allocated by anyone else. */
> 		}
> 
> 		please see __rmqueue_fallback(). it selects migration-type at 1st.
> 		Then, if you can pass start_migratetype of MIGLATE_ISOLATE,
> 		you can automatically strip all MIGRATE_ISOLATE pages from free_area[].
> 
> 		return chunk of pages.
> 	}
> ==
> 

Here is a rough code for this.
I'm sorry I can't have time to show enough good code. Maybe this cannot be
compiled. But you may be able to see what can be done with memory hotplug
or compaction code. I'll brush this up if someone has interest.
==


This is a code for creating isolated memory block of contiguous pages.

find_isolate_contig_block(unsigned long hint, unsigned long size)

will retrun [start, start+size] of isolated pages 
 - start > hint,
 - no memory holes within it.
 - page allocator will never touch pages within the range.

Of course, this can fail. This code makes use of memory-hotunplug's code.
But yes, you can think of reusing compaction codes. This is an example.
Not compiled at all...please don't see details.

---
 mm/isolation.c |  236 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 236 insertions(+)

Index: kametest/mm/isolation.c
===================================================================
--- /dev/null
+++ kametest/mm/isolation.c
@@ -0,0 +1,233 @@
+struct page_range {
+	unsigned long base, end, pages;
+};
+
+int __get_contig_block(unsigned long pfn, unsigned long nr_pages, void *arg)
+{
+	struct page_range *blockinfo = arg;
+
+	if (nr_pages > blockinfo->pages) {
+		blockinfo->base = pfn;
+		blockinfo->end = pfn + nr_pages;
+		return 1;
+	}
+	return 0;
+}
+
+
+unsigned long __find_contig_block(unsigned long base,
+		unsigned long end, unsigned long pages)
+{
+	unsigned long pfn, tmp, index;
+	struct page_range blockinfo;
+	int ret;
+
+	/* Skip memory holes */
+retry:
+	blockinfo.base = base;
+	blockinfo.end = end;
+	blockinfo.pages = pages;
+	ret = walk_system_ram_range(base, end - base, &blockinfo,
+		__get_contig_block);	
+	if (!ret)
+		return 0;
+	/* Ok, we gound contiguous memory chunk of size. Isolate it.*/
+	for (pfn = blockinfo->base; pfn + pages < blockinfo->end;) {
+
+		for (index = 0; index < nr_pages; index += pageblock_nr_pages)
+			struct page *page;
+
+			page = pfn_to_page(pfn+index);
+			if (set_migratetype_isoalte(page))
+				break;
+		}
+		if (index == nr_pages)
+			return pfn; /* [pfn...pfn+nr_pages) are isolated */
+		/* rollback */
+		for (tmp = 0; tmp < index; tmp += pageblock_nr_pages) {
+			page = pfn_to_page(pfn+tmp);
+			unset_migratetype_isolate(page);
+		} 
+		pfn += index;
+	}
+	/* failed ? */
+	if (blockinfo.end + pages < end) {
+		/* Move base address and find the next block */
+		base = blockinfo.end;
+		goto retry;
+	}
+	return 0;
+}
+
+unsigned long
+find_isolate_conting_block(unsigned long hint, unsigned long size)
+{
+	unsigned long base, found, end, blocks, pages;
+	unsigned long *map;
+	int nid, retry;
+	physaddr_t addr = 0;
+
+	pages = PAGE_ALIGN(size) >> PAGE_SHIFT;
+	pages = ALIGN(pages, pageblock_nr_pages);
+	blocks = pages/pageblock_nr_pages;
+	base = hint;
+
+retry:
+	for_each_node_state(nid, N_HIGH_MEMORY) {
+		unsigned long start;
+		pg_data_t *node = NODE_DATA(nid);
+
+		if (node->node_start_pfn + node->node_end_pfn  - base < pages)
+			continue;
+		if (base < node->node_start_pfn)
+			base = node->node_start_pfn;
+		end = node->node_end_pfn;
+		/* Maybe we can use this Node */
+		found = __find_contig_block(base, end, blocks);
+		if (found) /* Found ? */
+			break;
+		base = end; /* try next node*/
+	}
+	if (!found)
+		goto out;
+	/*
+	 * Ok, here, we have contiguous pageblock marked as "isolated"
+	 * try migration.
+ 	 */
+	retry = 5;
+	while (retry--) {
+		if (!do_migrate_range(found, found + pages))
+			break;
+		lru_add_drain_all();
+		flush_scheduled_work();
+		cond_resched();
+		drain_all_pages();
+	}
+	lru_add_drain_all();
+	flush_scheduled_work();
+	drain_all_pages();
+	offlined_pages = check_pages_isolated(found, found+pages);
+	/* Ok, here, [found...found+pages) memory are isolated */
+out:
+	return found;
+}

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
