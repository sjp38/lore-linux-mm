Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 15BFA6B0092
	for <linux-mm@kvack.org>; Tue, 20 Nov 2012 05:49:00 -0500 (EST)
Received: from eusync3.samsung.com (mailout2.w1.samsung.com [210.118.77.12])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0MDS008FJ8Q1TZ60@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 20 Nov 2012 10:49:13 +0000 (GMT)
Received: from [127.0.0.1] ([106.116.147.30])
 by eusync3.samsung.com (Oracle Communications Messaging Server 7u4-23.01
 (7.0.4.23.0) 64bit (built Aug 10 2011))
 with ESMTPA id <0MDS00J4A8P8HM70@eusync3.samsung.com> for linux-mm@kvack.org;
 Tue, 20 Nov 2012 10:48:57 +0000 (GMT)
Message-id: <50AB600C.5010801@samsung.com>
Date: Tue, 20 Nov 2012 11:48:44 +0100
From: Marek Szyprowski <m.szyprowski@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH] mm: dmapool: use provided gfp flags for all
 dma_alloc_coherent() calls
References: <1352356737-14413-1-git-send-email-m.szyprowski@samsung.com>
 <20121119001846.GB22106@titan.lakedaemon.net>
 <20121119144826.f59667b2.akpm@linux-foundation.org>
In-reply-to: <20121119144826.f59667b2.akpm@linux-foundation.org>
Content-type: text/plain; charset=UTF-8; format=flowed
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Jason Cooper <jason@lakedaemon.net>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Michal Hocko <mhocko@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-arm-kernel@lists.infradead.org, linaro-mm-sig@lists.linaro.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Thomas Petazzoni <thomas.petazzoni@free-electrons.com>, Andrew Lunn <andrew@lunn.ch>, Arnd Bergmann <arnd@arndb.de>, Kyungmin Park <kyungmin.park@samsung.com>, Soren Moch <smoch@web.de>, Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>

Hello,

On 11/19/2012 11:48 PM, Andrew Morton wrote:
> On Sun, 18 Nov 2012 19:18:46 -0500
> Jason Cooper <jason@lakedaemon.net> wrote:
>
> > I've added the maintainers for mm/*.  Hopefully they can let us know if
> > this is good for v3.8...
>
> As Marek has inexplicably put this patch into linux-next via his tree,
> we don't appear to be getting a say in the matter!

I've just put this patch to linux-next via my dma-mapping tree to give it
some testing asap to check if other changes to arm dma-mapping are required
or not.

> The patch looks good to me.  That open-coded wait loop predates the
> creation of bitkeeper tree(!) but doesn't appear to be needed.  There
> will perhaps be some behavioural changes observable for GFP_KERNEL
> callers as dma_pool_alloc() will no longer dip into page reserves but I
> see nothing special about dma_pool_alloc() which justifies doing that
> anyway.
>
> The patch makes pool->waitq and its manipulation obsolete, but it
> failed to remove all that stuff.

Right, I missed that part, I will update it asap.

> The changelog failed to describe the problem which Soren reported.
> That should be included, and as the problem sounds fairly serious we
> might decide to backport the fix into -stable kernels.

Ok, I will extend the changelog.

> dma_pool_alloc()'s use of a local "struct dma_page *page" is
> distressing - MM developers very much expect a local called "page" to
> have type "struct page *".  But that's a separate issue.

I will prepare a separate patch cleaning it. I was also a bit surprised
by such naming scheme, but it is probably related to the fact that this
come has not been touched much since a very ancient times.

> As this patch is already in -next and is stuck there for two more
> weeks I can't (or at least won't) merge this patch, so I can't help
> with any of the above.

I will fix both issues in the next version of the patch. Would like to
merge it to your tree or should I keep it in my dma-mapping tree?

Best regards
-- 
Marek Szyprowski
Samsung Poland R&D Center


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
