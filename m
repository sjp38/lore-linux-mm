Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9359B900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 03:21:14 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id bj1so106572pad.15
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 00:21:14 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id rt8si462617pbc.249.2014.10.28.00.21.12
        for <linux-mm@kvack.org>;
        Tue, 28 Oct 2014 00:21:13 -0700 (PDT)
Date: Tue, 28 Oct 2014 16:22:31 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v4 1/4] mm/page_alloc: fix incorrect isolation behavior
 by rechecking migratetype
Message-ID: <20141028072231.GC27813@js1304-P5Q-DELUXE>
References: <1414051821-12769-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1414051821-12769-2-git-send-email-iamjoonsoo.kim@lge.com>
 <544E1F70.1030106@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <544E1F70.1030106@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stable@vger.kernel.org

On Mon, Oct 27, 2014 at 11:33:20AM +0100, Vlastimil Babka wrote:
> On 10/23/2014 10:10 AM, Joonsoo Kim wrote:
> > Changes from v3:
> > Add one more check in free_one_page() that checks whether migratetype is
> > MIGRATE_ISOLATE or not. Without this, abovementioned case 1 could happens.
> 
> Good catch.
> 
> > Cc: <stable@vger.kernel.org>
> > Signed-off-by: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> 
> Acked-by: Vlastimil Babka <vbabka@suse.cz>
> 
> (minor suggestion below)
> 
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -749,9 +749,16 @@ static void free_one_page(struct zone *zone,
> >  	if (nr_scanned)
> >  		__mod_zone_page_state(zone, NR_PAGES_SCANNED, -nr_scanned);
> >  
> > +	if (unlikely(has_isolate_pageblock(zone) ||
> 
> Would it make any difference if this was read just once and not in each
> loop iteration?
> 
> 

I guess that you'd like to say this to patch 2.
I can do it, but, it doesn't any difference in terms of performance,
because we access zone's member variable in each loop iteration
in __free_one_page().

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
