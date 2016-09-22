Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f69.google.com (mail-oi0-f69.google.com [209.85.218.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7104D6B0269
	for <linux-mm@kvack.org>; Thu, 22 Sep 2016 01:24:16 -0400 (EDT)
Received: by mail-oi0-f69.google.com with SMTP id i193so180910976oib.3
        for <linux-mm@kvack.org>; Wed, 21 Sep 2016 22:24:16 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id 78si1028118iog.59.2016.09.21.22.24.15
        for <linux-mm@kvack.org>;
        Wed, 21 Sep 2016 22:24:15 -0700 (PDT)
Date: Thu, 22 Sep 2016 14:32:18 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 0/6] Introduce ZONE_CMA
Message-ID: <20160922053217.GB27958@js1304-P5Q-DELUXE>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <8737lnudq6.fsf@linux.vnet.ibm.com>
 <CAAmzW4MZdwn2-Pd_58B+vXKOyPybdfx4FPRvxNaADnDCryo7Ng@mail.gmail.com>
 <87shtmsfpy.fsf@linux.vnet.ibm.com>
 <20160831080300.GB22757@js1304-P5Q-DELUXE>
 <87eg54rx1w.fsf@linux.vnet.ibm.com>
 <87eg4dwbr4.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87eg4dwbr4.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@techsingularity.net>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Sep 21, 2016 at 08:17:27PM +0530, Aneesh Kumar K.V wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> 
> > Joonsoo Kim <iamjoonsoo.kim@lge.com> writes:
> >
> >> On Tue, Aug 30, 2016 at 04:09:37PM +0530, Aneesh Kumar K.V wrote:
> >>> Joonsoo Kim <js1304@gmail.com> writes:
> >>> 
> >>> > 2016-08-29 18:27 GMT+09:00 Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>:
> >>> >> js1304@gmail.com writes:
> >>> >>
> >>> >>> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>> >>>
> >>> >>> Hello,
> >>> >>>
> >>> >>> Changes from v4
> >>> >>> o Rebase on next-20160825
> >>> >>> o Add general fix patch for lowmem reserve
> >>> >>> o Fix lowmem reserve ratio
> >>> >>> o Fix zone span optimizaion per Vlastimil
> >>> >>> o Fix pageset initialization
> >>> >>> o Change invocation timing on cma_init_reserved_areas()
> >>> >>
> >>> >> I don't see much information regarding how we interleave between
> >>> >> ZONE_CMA and other zones for movable allocation. Is that explained in
> >>> >> any of the patch ? The fair zone allocator got removed by
> >>> >> e6cbd7f2efb433d717af72aa8510a9db6f7a7e05
> >>> >
> >>> > Interleaving would not work since the fair zone allocator policy is removed.
> >>> > I don't think that it's a big problem because it is just matter of
> >>> > timing to fill
> >>> > up the memory. Eventually, memory on ZONE_CMA will be fully used in
> >>> > any case.
> >>> 
> >>> Does that mean a CMA allocation will now be slower because in most case we
> >>> will need to reclaim ? The zone list will now have ZONE_CMA in the
> >>> beginning right ?
> >>
> >> ZONE_CMA will be used first but I don't think that CMA allocation will
> >> be slower. In most case, memory would be fully used (usually
> >> by page cache). So, we need reclaim or migration in any case.
> >
> > Considering that the upstream kernel doesn't allow migration of THP
> > pages, this would mean that migrate will fail in most case if we have
> > THP enabled and the THP allocation request got satisfied via ZONE_CMA.
> > Isn't that going to be a problem ?
> >
> 
> Even though we have the issues of migration failures due to pinned and
> THP pages in ZONE_CMA, overall the code is simpler. IMHO we should get
> this upstream now and work on solving those issues later.

Yep! I will take a look on those problems after merging this patchset.

> 
> You can add for the complete series.
> 
> Reviewed-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Thanks!

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
