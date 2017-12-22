Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 476C86B0038
	for <linux-mm@kvack.org>; Thu, 21 Dec 2017 19:11:04 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id e26so19130391pfi.15
        for <linux-mm@kvack.org>; Thu, 21 Dec 2017 16:11:04 -0800 (PST)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id f11si14269012pgs.451.2017.12.21.16.11.02
        for <linux-mm@kvack.org>;
        Thu, 21 Dec 2017 16:11:03 -0800 (PST)
Date: Fri, 22 Dec 2017 09:11:14 +0900
From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
Subject: Re: [PATCH v2 0/3] mm/cma: manage the memory of the CMA area by
 using the ZONE_MOVABLE
Message-ID: <20171222001113.GA1729@js1304-P5Q-DELUXE>
References: <1512114786-5085-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20171208143719.901b742d5238b829edac3b14@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20171208143719.901b742d5238b829edac3b14@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Laura Abbott <lauraa@codeaurora.org>, Minchan Kim <minchan@kernel.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Michal Nazarewicz <mina86@mina86.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Vlastimil Babka <vbabka@suse.cz>, Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@lge.com, Tony Lindgren <tony@atomide.com>, Michal Hocko <mhocko@kernel.org>

On Fri, Dec 08, 2017 at 02:37:19PM -0800, Andrew Morton wrote:
> On Fri,  1 Dec 2017 16:53:03 +0900 js1304@gmail.com wrote:
> 
> > From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> > 
> > v2
> > o previous failure in linux-next turned out that it's not the problem of
> > this patchset. It was caused by the wrong assumption by specific
> > architecture.
> > 
> > lkml.kernel.org/r/20171114173719.GA28152@atomide.com
> > 
> > o add missing cache flush to the patch "ARM: CMA: avoid double mapping
> > to the CMA area if CONFIG_HIGHMEM = y"
> > 
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
> 
> mhocko had issues with that patch which weren't addressed?
> http://lkml.kernel.org/r/20170914132452.d5klyizce72rhjaa@dhcp22.suse.cz

Hello, Andrew.

Sorry for late response. I was on a long vacation.

I don't do anything on that patch yet. In fact, that patch isn't really
necessary to this patchset so I didn't include it into this patchset.

I will re-submit that patch after fixing the issue.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
