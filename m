Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 12D946B01F2
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 04:21:52 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp ([10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id o7R8LomN031128
	for <linux-mm@kvack.org> (envelope-from kamezawa.hiroyu@jp.fujitsu.com);
	Fri, 27 Aug 2010 17:21:50 +0900
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id D6DC145DE51
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:21:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id B835145DE50
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:21:49 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 9D1691DB803B
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:21:49 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.249.87.104])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id F06F4E18006
	for <linux-mm@kvack.org>; Fri, 27 Aug 2010 17:21:48 +0900 (JST)
Date: Fri, 27 Aug 2010 17:16:39 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH/RFCv4 0/6] The Contiguous Memory Allocator framework
Message-Id: <20100827171639.83c8642c.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <AANLkTimB+s0tO=wrODAU4qCaZnCBoLZ2A9pGjR_jheOj@mail.gmail.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: =?UTF-8?B?TWljaGHFgg==?= Nazarewicz <m.nazarewicz@samsung.com>, Andrew Morton <akpm@linux-foundation.org>, Hans Verkuil <hverkuil@xs4all.nl>, Daniel Walker <dwalker@codeaurora.org>, Russell King <linux@arm.linux.org.uk>, Jonathan Corbet <corbet@lwn.net>, Peter Zijlstra <peterz@infradead.org>, Pawel Osciak <p.osciak@samsung.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-kernel@vger.kernel.org, FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>, linux-mm@kvack.org, Kyungmin Park <kyungmin.park@samsung.com>, Zach Pfeffer <zpfeffer@codeaurora.org>, Mark Brown <broonie@opensource.wolfsonmicro.com>, Mel Gorman <mel@csn.ul.ie>, linux-media@vger.kernel.org, linux-arm-kernel@lists.infradead.org, Marek Szyprowski <m.szyprowski@samsung.com>
List-ID: <linux-mm.kvack.org>

On Thu, 26 Aug 2010 18:36:24 +0900
Minchan Kim <minchan.kim@gmail.com> wrote:

> On Thu, Aug 26, 2010 at 1:30 PM, KAMEZAWA Hiroyuki
> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> > On Thu, 26 Aug 2010 13:06:28 +0900
> > Minchan Kim <minchan.kim@gmail.com> wrote:
> >
> >> On Thu, Aug 26, 2010 at 12:44 PM, KAMEZAWA Hiroyuki
> >> <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> > On Thu, 26 Aug 2010 11:50:17 +0900
> >> > KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com> wrote:
> >> >
> >> >> 128MB...too big ? But it's depend on config.
> >> >>
> >> >> IBM's ppc guys used 16MB section, and recently, a new interface to shrink
> >> >> the number of /sys files are added, maybe usable.
> >> >>
> >> >> Something good with this approach will be you can create "cma" memory
> >> >> before installing driver.
> >> >>
> >> >> But yes, complicated and need some works.
> >> >>
> >> > Ah, I need to clarify what I want to say.
> >> >
> >> > With compaction, it's helpful, but you can't get contiguous memory larger
> >> > than MAX_ORDER, I think. To get memory larger than MAX_ORDER on demand,
> >> > memory hot-plug code has almost all necessary things.
> >>
> >> True. Doesn't patch's idea of Christoph helps this ?
> >> http://lwn.net/Articles/200699/
> >>
> >
> > yes, I think so. But, IIRC, A it's own purpose of Chirstoph's work is
> > for removing zones. please be careful what's really necessary.
> 
> Ahh. Sorry for missing point.
> You're right. The patch can't help our problem.
> 
> How about changing following this?
> The thing is MAX_ORDER is static. But we want to avoid too big
> MAX_ORDER of whole zones to support devices which requires big
> allocation chunk.
> So let's add MAX_ORDER into each zone and then, each zone can have
> different max order.
> For example, while DMA[32], NORMAL, HIGHMEM can have normal size 11,
> MOVABLE zone could have a 15.
> 
> This approach has a big side effect?
> 

Hm...need to check hard coded MAX_ORDER usages...I don't think
side-effect is big. Hmm. But I think enlarging MAX_ORDER isn't an
important thing. A code which strips contiguous chunks of pages from
buddy allocator is a necessaty thing, as..

What I can think of at 1st is...
==
	int steal_pages(unsigned long start_pfn, unsigned long end_pfn)
	{
		/* Be careful mutal execution with memory hotplug, because reusing code */

		split [start_pfn, end_pfn) to pageblock_order
		
		for each pageblock in the range {
			Mark this block as MIGRATE_ISOLATE
			try-to-free pages in the range or
			migrate pages in the range to somewhere.
			/* Here all pages in the range are on buddy allocator
			and free and never be allocated by anyone else. */
		}

		please see __rmqueue_fallback(). it selects migration-type at 1st.
		Then, if you can pass start_migratetype of MIGLATE_ISOLATE,
		you can automatically strip all MIGRATE_ISOLATE pages from free_area[].

		return chunk of pages.
	}
==

Thanks,
-Kame



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
