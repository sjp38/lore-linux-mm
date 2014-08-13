Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 3279C6B0035
	for <linux-mm@kvack.org>; Wed, 13 Aug 2014 04:21:00 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id lf10so14592541pab.1
        for <linux-mm@kvack.org>; Wed, 13 Aug 2014 01:20:59 -0700 (PDT)
Received: from lgeamrelo02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id yp8si946752pac.193.2014.08.13.01.20.58
        for <linux-mm@kvack.org>;
        Wed, 13 Aug 2014 01:20:59 -0700 (PDT)
Date: Wed, 13 Aug 2014 17:20:57 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/8] mm/page_alloc: correct to clear guard attribute
 in DEBUG_PAGEALLOC
Message-ID: <20140813082057.GD30451@js1304-P5Q-DELUXE>
References: <1407309517-3270-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1407309517-3270-5-git-send-email-iamjoonsoo.kim@lge.com>
 <20140812014523.GB23418@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140812014523.GB23418@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Zhang Yanfei <zhangyanfei@cn.fujitsu.com>, "Srivatsa S. Bhat" <srivatsa.bhat@linux.vnet.ibm.com>, Tang Chen <tangchen@cn.fujitsu.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, Wen Congyang <wency@cn.fujitsu.com>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Laura Abbott <lauraa@codeaurora.org>, Heesub Shin <heesub.shin@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Ritesh Harjani <ritesh.list@gmail.com>, t.stanislaws@samsung.com, Gioh Kim <gioh.kim@lge.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 12, 2014 at 01:45:23AM +0000, Minchan Kim wrote:
> On Wed, Aug 06, 2014 at 04:18:30PM +0900, Joonsoo Kim wrote:
> > In __free_one_page(), we check the buddy page if it is guard page.
> > And, if so, we should clear guard attribute on the buddy page. But,
> > currently, we clear original page's order rather than buddy one's.
> > This doesn't have any problem, because resetting buddy's order
> > is useless and the original page's order is re-assigned soon.
> > But, it is better to correct code.
> > 
> > Additionally, I change (set/clear)_page_guard_flag() to
> > (set/clear)_page_guard() and makes these functions do all works
> > needed for guard page. This may make code more understandable.
> > 
> > One more thing, I did in this patch, is that fixing freepage accounting.
> > If we clear guard page and link it onto isolate buddy list, we should
> > not increase freepage count.
> 
> You are saying just "shouldn't do that" but don't say "why" and "result"
> I know the reason but as you know, I'm one of the person who is rather
> familiar with this part but I guess others should spend some time to get.
> Kind detail description is never to look down on person. :)

Hmm. In fact, the reason is already mentioned in cover letter, but,
it is better to write it here.

Will do.

> > 
> 
> Nice catch, Joonsoo! But what make me worry is is this patch makes 3 thing
> all at once.
> 
> 1. fix - no candidate for stable
> 2. clean up
> 3. fix - candidate for stable.
> 
> Could you separate 3 and (1,2) in next spin?
> 

Okay!

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
