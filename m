Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx142.postini.com [74.125.245.142])
	by kanga.kvack.org (Postfix) with SMTP id 2FDF76B0069
	for <linux-mm@kvack.org>; Wed, 19 Sep 2012 04:00:46 -0400 (EDT)
Date: Wed, 19 Sep 2012 17:03:21 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v4 1/4] mm: fix tracing in free_pcppages_bulk()
Message-ID: <20120919080321.GB13234@bbox>
References: <1347632974-20465-1-git-send-email-b.zolnierkie@samsung.com>
 <1347632974-20465-2-git-send-email-b.zolnierkie@samsung.com>
 <50596F27.4080208@jp.fujitsu.com>
 <20120919073245.GA13234@bbox>
 <50597829.9010801@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <50597829.9010801@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: Bartlomiej Zolnierkiewicz <b.zolnierkie@samsung.com>, linux-mm@kvack.org, m.szyprowski@samsung.com, mina86@mina86.com, mgorman@suse.de, hughd@google.com, kyungmin.park@samsung.com

On Wed, Sep 19, 2012 at 04:45:45PM +0900, Yasuaki Ishimatsu wrote:
> Hi Minchan,
> 
> 2012/09/19 16:32, Minchan Kim wrote:
> >Hi Yasuaki,
> >
> >On Wed, Sep 19, 2012 at 04:07:19PM +0900, Yasuaki Ishimatsu wrote:
> >>Hi Bartlomiej,
> >>
> >>2012/09/14 23:29, Bartlomiej Zolnierkiewicz wrote:
> >>>page->private gets re-used in __free_one_page() to store page order
> >>>(so trace_mm_page_pcpu_drain() may print order instead of migratetype)
> >>>thus migratetype value must be cached locally.
> >>>
> >>>Fixes regression introduced in a701623 ("mm: fix migratetype bug
> >>>which slowed swapping").
> >>
> >>I think the regression has been alreadly fixed by following Mincahn's patches.
> >>
> >>https://lkml.org/lkml/2012/9/6/635
> >>
> >>=> Hi Minchan,
> >>
> >>    Am I wrong?
> >
> >This patch isn't related to mine.
> 
> According to the description, the regression occurs by clearing migratetype
> info from page->private at __free_one_page(). If we apply your patches,
> migratetype info is stored into page->index. So the migratetype info is not
> cleared. Thus we do not need to cache the info locally.

Brain-dead. I totally forgot my implementation.
You're absolutely right but it's a just side-effect of my implementation
so description of my patch doesn't say anything about this bug.

Although my patch solve this problem by chance, we should merge 
this patch before mine and rebase mine onto this, I think.

Andrew?


-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
