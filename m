Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 729126B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 02:34:23 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id n85so45687741pfi.4
        for <linux-mm@kvack.org>; Sun, 06 Nov 2016 23:34:23 -0800 (PST)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id e80si29786252pfl.8.2016.11.06.23.25.10
        for <linux-mm@kvack.org>;
        Sun, 06 Nov 2016 23:25:11 -0800 (PST)
Date: Mon, 7 Nov 2016 16:27:02 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v6 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20161107072702.GC21159@js1304-P5Q-DELUXE>
References: <1476414196-3514-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1476414196-3514-3-git-send-email-iamjoonsoo.kim@lge.com>
 <58184B28.8090405@hisilicon.com>
 <20161107061500.GA21159@js1304-P5Q-DELUXE>
 <58202881.5030004@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <58202881.5030004@hisilicon.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Chen Feng <puck.chen@hisilicon.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Nov 07, 2016 at 03:08:49PM +0800, Chen Feng wrote:
> 
> 
> On 2016/11/7 14:15, Joonsoo Kim wrote:
> > On Tue, Nov 01, 2016 at 03:58:32PM +0800, Chen Feng wrote:
> >> Hello, I hava a question on cma zone.
> >>
> >> When we have cma zone, cma zone will be the highest zone of system.
> >>
> >> In android system, the most memory allocator is ION. Media system will
> >> alloc unmovable memory from it.
> >>
> >> On low memory scene, will the CMA zone always do balance?
> > 
> > Allocation request for low zone (normal zone) would not cause CMA zone
> > to be balanced since it isn't helpful.
> > 
> Yes. But the cma zone will run out soon. And it always need to do balance.
> 
> How about use migrate cma before movable and let cma type to fallback movable.
> 
> https://www.mail-archive.com/linux-kernel@vger.kernel.org/msg1263745.html

ZONE_CMA approach will act like as your solution. Could you elaborate
more on the problem of zone approach?

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
