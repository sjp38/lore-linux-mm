Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 7924D6008E4
	for <linux-mm@kvack.org>; Tue,  3 Aug 2010 00:24:02 -0400 (EDT)
Date: Tue, 3 Aug 2010 12:28:35 +0800
From: Wu Fengguang <fengguang.wu@intel.com>
Subject: Re: Over-eager swapping
Message-ID: <20100803042835.GA17377@localhost>
References: <20100802124734.GI2486@arachsys.com>
 <AANLkTinnWQA-K6r_+Y+giEC9zs-MbY6GFs8dWadSq0kh@mail.gmail.com>
 <20100803033108.GA23117@arachsys.com>
 <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <AANLkTinjmZOOaq7FgwJOZ=UNGS8x8KtQWZg6nv7fqJMe@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Chris Webb <chris@arachsys.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On Tue, Aug 03, 2010 at 12:09:18PM +0800, Minchan Kim wrote:
> On Tue, Aug 3, 2010 at 12:31 PM, Chris Webb <chris@arachsys.com> wrote:
> > Minchan Kim <minchan.kim@gmail.com> writes:
> >
> >> Another possibility is _zone_reclaim_ in NUMA.
> >> Your working set has many anonymous page.
> >>
> >> The zone_reclaim set priority to ZONE_RECLAIM_PRIORITY.
> >> It can make reclaim mode to lumpy so it can page out anon pages.
> >>
> >> Could you show me /proc/sys/vm/[zone_reclaim_mode/min_unmapped_ratio] ?
> >
> > Sure, no problem. On the machine with the /proc/meminfo I showed earlier,
> > these are
> >
> > A # cat /proc/sys/vm/zone_reclaim_mode
> > A 0
> > A # cat /proc/sys/vm/min_unmapped_ratio
> > A 1
> 
> if zone_reclaim_mode is zero, it doesn't swap out anon_pages.

If there are lots of order-1 or higher allocations, anonymous pages
will be randomly evicted, regardless of their LRU ages. This is
probably another factor why the users claim. Are there easy ways to
confirm this other than patching the kernel?

Chris, what's in your /proc/slabinfo?

Thanks,
Fengguang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
