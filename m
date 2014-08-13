Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f47.google.com (mail-pa0-f47.google.com [209.85.220.47])
	by kanga.kvack.org (Postfix) with ESMTP id 941846B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 04:19:26 -0400 (EDT)
Received: by mail-pa0-f47.google.com with SMTP id kx10so14310767pab.6
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 01:19:26 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id uf7si978016pbc.8.2014.08.13.01.19.24
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 01:19:25 -0700 (PDT)
Date: Wed, 13 Aug 2014 17:19:21 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/8] mm/isolation: remove unstable check for isolated
 page
Message-ID: <20140813081921.GC30451@js1304-P5Q-DELUXE>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-4-git-send-email-iamjoonsoo.kim@lge.com>
 <87a97b5qi0.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87a97b5qi0.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Aug 11, 2014 at 02:53:35PM +0530, Aneesh Kumar K.V wrote:
> Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> 
> > The check '!PageBuddy(page) && page_count(page) == 0 &&
> > migratetype == MIGRATE_ISOLATE' would mean the page on free processing.
> > Although it could go into buddy allocator within a short time,
> > futher operation such as isolate_freepages_range() in CMA, called after
> > test_page_isolated_in_pageblock(), could be failed due to this unstability
> > since it requires that the page is on buddy. I think that removing
> > this unstability is good thing.
> 
> Is that true in case of check_pages_isolated_cb ? Does that require
> PageBuddy to be true ?

I think so.

> 
> >
> > And, following patch makes isolated freepage has new status matched with
> > this condition and this check is the obstacle to that change. So remove
> > it.
> 
> Can you quote the patch summary in the above case ? ie, something like
> 
> And the followiing patch "mm/....." makes isolate freepage.
> 

Okay.

"mm/isolation: change pageblock isolation logic to fix freepage
counting bugs" introduce PageIsolated() and mark freepages
PageIsolated() during isolation. Those pages are !PageBuddy() and
page_count() == 0.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
