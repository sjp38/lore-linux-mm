Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f69.google.com (mail-pa0-f69.google.com [209.85.220.69])
	by kanga.kvack.org (Postfix) with ESMTP id B22486B0038
	for <linux-mm@kvack.org>; Wed, 31 Aug 2016 03:51:42 -0400 (EDT)
Received: by mail-pa0-f69.google.com with SMTP id le9so78634635pab.0
        for <linux-mm@kvack.org>; Wed, 31 Aug 2016 00:51:42 -0700 (PDT)
Received: from lgeamrelo13.lge.com (LGEAMRELO13.lge.com. [156.147.23.53])
        by mx.google.com with ESMTP id 194si49607430pfy.175.2016.08.31.00.51.41
        for <linux-mm@kvack.org>;
        Wed, 31 Aug 2016 00:51:41 -0700 (PDT)
Date: Wed, 31 Aug 2016 16:58:24 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v5 2/6] mm/cma: introduce new zone, ZONE_CMA
Message-ID: <20160831075823.GA22757@js1304-P5Q-DELUXE>
References: <1472447255-10584-1-git-send-email-iamjoonsoo.kim@lge.com>
 <1472447255-10584-3-git-send-email-iamjoonsoo.kim@lge.com>
 <87vayisfx3.fsf@linux.vnet.ibm.com>
 <87pooqsa41.fsf@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87pooqsa41.fsf@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue, Aug 30, 2016 at 06:10:46PM +0530, Aneesh Kumar K.V wrote:
> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
> 
> > ....
> >
> >>  static inline void check_highest_zone(enum zone_type k)
> >>  {
> >> -	if (k > policy_zone && k != ZONE_MOVABLE)
> >> +	if (k > policy_zone && k != ZONE_MOVABLE && !is_zone_cma_idx(k))
> >>  		policy_zone = k;
> >>  }
> >>
> >
> >
> > Should we apply policy to allocation from ZONE CMA ?. CMA reserve
> > happens early and may mostly come from one node. Do we want the
> > CMA allocation to fail if we use mbind(MPOL_BIND) with a node mask not
> > including that node on which CMA is reserved, considering CMA memory is
> > going to be used for special purpose.
> 
> Looking at this again, I guess CMA alloc is not going to depend on
> memory policy, but this is for other movable allocation ?

This is for usual file cache or anonymous page allocation. IIUC,
policy_zone is used to determine if mempolicy should be applied or not
and setting policy_zone to ZONE_CMA makes mempolicy less useful.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
