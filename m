Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id E03B76B02F3
	for <linux-mm@kvack.org>; Sun, 27 Aug 2017 20:30:44 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id t193so19892151pgc.4
        for <linux-mm@kvack.org>; Sun, 27 Aug 2017 17:30:44 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id i35si6537848plg.727.2017.08.27.17.30.43
        for <linux-mm@kvack.org>;
        Sun, 27 Aug 2017 17:30:43 -0700 (PDT)
Date: Mon, 28 Aug 2017 09:31:20 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH 0/3] mm/cma: manage the memory of the CMA area by using
 the ZONE_MOVABLE
Message-ID: <20170828003120.GC9167@js1304-P5Q-DELUXE>
References: <1503556593-10720-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170825143213.5c7de68783b78fafb461c845@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170825143213.5c7de68783b78fafb461c845@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, mgorman@techsingularity.net, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com

On Fri, Aug 25, 2017 at 02:32:13PM -0700, Andrew Morton wrote:
> On Thu, 24 Aug 2017 15:36:30 +0900 js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > This patchset is the follow-up of the discussion about the
> > "Introduce ZONE_CMA (v7)" [1]. Please reference it if more information
> > is needed.
> > 
> > In this patchset, the memory of the CMA area is managed by using
> > the ZONE_MOVABLE. Since there is another type of the memory in this zone,
> > we need to maintain a migratetype for the CMA memory to account
> > the number of the CMA memory. So, unlike previous patchset, there is
> > less deletion of the code.
> > 
> > Otherwise, there is no big change.
> > 
> > Motivation of this patchset is described in the commit description of
> > the patch "mm/cma: manage the memory of the CMA area by using
> > the ZONE_MOVABLE". Please refer it for more information.
> > 
> > This patchset is based on linux-next-20170822 plus
> > "mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE".
> > 
> 
> But "mm/page_alloc: don't reserve ZONE_HIGHMEM for ZONE_MOVABLE" did
> not do very well at review - both Michal and Vlastimil are looking for
> changes.  So we're not ready for a patch series which depends upon that
> one?

Oops. I checked again and I found that this patchset is not dependant
to that patch. It's just leftover from ZONE_CMA patchset.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
