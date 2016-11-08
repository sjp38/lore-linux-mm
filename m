Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 681916B0038
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 23:05:21 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so61077089pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 20:05:21 -0800 (PST)
Received: from lgeamrelo11.lge.com (LGEAMRELO11.lge.com. [156.147.23.51])
        by mx.google.com with ESMTP id t17si34683440pgi.158.2016.11.07.19.57.48
        for <linux-mm@kvack.org>;
        Mon, 07 Nov 2016 19:57:48 -0800 (PST)
Date: Tue, 8 Nov 2016 12:59:43 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20161108035942.GA31767@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com>
 <20161107061500.GA21159@js1304-P5Q-DELUXE>
 <58202881.5030004@hisilicon.com>
 <20161107072702.GC21159@js1304-P5Q-DELUXE>
 <582030CB.80905@hisilicon.com>
 <5820313A.80207@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <5820313A.80207@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, saberlily.xia@hisilicon.com, Zhuangluan Su <suzhuangluan@hisilicon.com>, Dan Zhao <dan.zhao@hisilicon.com>

On Mon, Nov 07, 2016 at 03:46:02PM +0800, Chen Feng wrote:
> 
> 
> On 2016/11/7 15:44, Chen Feng wrote:
> > On 2016/11/7 15:27, Joonsoo Kim wrote:
> >> On Mon, Nov 07, 2016 at 03:08:49PM +0800, Chen Feng wrote:
> >>>
> >>>
> >>> On 2016/11/7 14:15, Joonsoo Kim wrote:
> >>>> On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
> >>>>> Hello, I hava a question on cma zone.
> >>>>>
> >>>>> When we have cma zone, cma zone will be the highest zone of system.
> >>>>>
> >>>>> In android system, the most memory allocator is ION. Media system will
> >>>>> alloc unmovable memory from it.
> >>>>>
> >>>>> On low memory scene, will the CMA zone always do balance?
> >>>>
> >>>> Allocation request for low zone (normal zone) would not cause CMA zone
> >>>> to be balanced since it isn't helpful.
> >>>>
> >>> Yes. But the cma zone will run out soon. And it always need to do balance.
> >>>
> >>> How about use migrate cma before movable and let cma type to fallback movable.
> >>>
> >>> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1263745.html
> >>
> >> ZONE_CMA approach will act like as your solution. Could you elaborate
> >> more on the problem of zone approach?
> >>
> > 
> > The ZONE approach is that makes cma pages in a zone. It can cause a higher swapin/out
> > than use migrate cma first.

Interesting result. I should look at it more deeply. Could you explain
me why the ZONE approach causes a higher swapin/out?

> > 
> > The higher swapin/out may have a performance effect to application. The application may
> > use too much time swapin memory.
> > 
> > You can see my tested result attached for detail. And the baseline is result of [1].
> > 
> > 
> My test case is run 60 applications and alloc 512MB ION memory.
> 
> Repeat this action 50 times

Could you tell me more detail about your test?
Kernel version? Total Memory? Total CMA Memory? Android system? What
type of memory does ION uses? Other statistics? Etc...

If it tested on the Android, I'm not sure that we need to consider
it's result. Android has a lowmemory killer which is quitely different
with normal reclaim behaviour.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
