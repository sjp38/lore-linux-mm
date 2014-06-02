Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f42.google.com (mail-pb0-f42.google.com [209.85.160.42])
	by kanga.kvack.org (Postfix) with ESMTP id F29BB6B0031
	for <linux-mm@kvack.org>; Mon,  2 Jun 2014 02:14:31 -0400 (EDT)
Received: by mail-pb0-f42.google.com with SMTP id md12so3893466pbc.1
        for <linux-mm@kvack.org>; Sun, 01 Jun 2014 23:14:31 -0700 (PDT)
Received: from lgemrelse6q.lge.com (LGEMRELSE6Q.lge.com. [156.147.1.121])
        by mx.google.com with ESMTP id ql2si14587276pbb.240.2014.06.01.23.14.29
        for <linux-mm@kvack.org>;
        Sun, 01 Jun 2014 23:14:31 -0700 (PDT)
Date: Mon, 2 Jun 2014 15:17:51 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 2/3] CMA: aggressively allocate the pages on cma
 reserved memory when not used
Message-ID: <20140602061751.GA7713@js1304-P5Q-DELUXE>
References: <1401260672-28339-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1401260672-28339-3-git-send-email-iamjoonsoo.kim@lge.com>
 <5386E0CA.5040201@lge.com>
 <20140529074847.GA7554@js1304-P5Q-DELUXE>
 <5386EB3E.5090007@lge.com>
 <20140530004514.GB8906@js1304-P5Q-DELUXE>
 <xa1tha46hl1w.fsf@mina86.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <xa1tha46hl1w.fsf@mina86.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Nazarewicz <mina86@mina86.com>
Cc: Gioh Kim <gioh.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Heesub Shin <heesub.shin@samsung.com>, Marek Szyprowski <m.szyprowski@samsung.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, May 31, 2014 at 09:02:51AM +0900, Michal Nazarewicz wrote:
> > On Thu, May 29, 2014 at 05:09:34PM +0900, Gioh Kim wrote:
> >> Is IS_ENABLED(CONFIG_CMA) necessary?
> >> What about if (migratetype == MIGRATE_MOVABLE && zone->managed_cma_pages) ?
> 
> On Fri, May 30 2014, Joonsoo Kim <iamjoonsoo.kim@lge.com> wrote:
> > Yes, field, managed_cma_pages exists only if CONFIG_CMA is enabled, so
> > removing IS_ENABLE(CONFIG_CMA) would break the build.
> 
> That statement makes no sense.  If zone->managed_cma_pages not being
> defined is the problem, what you need is:
> 
> +#ifdef CONFIG_CMA
> +	if (migratetype == MIGRATE_MOVABLE && zone->managed_cma_pages)
> +		page = __rmqueue_cma(zone, order);
> +#endif
> 
> If you use IS_ENABLED, zone-managed_cma_pages has to be defined
> regardless of result of state of CONFIG_CMA.


Hello,

Oops. I totally misunderstand how IS_ENABLED works.
Thanks for spotting this.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
