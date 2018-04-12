Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 217FD6B0007
	for <linux-mm@kvack.org>; Thu, 12 Apr 2018 08:01:38 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id i137so2761620pfe.0
        for <linux-mm@kvack.org>; Thu, 12 Apr 2018 05:01:38 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n1-v6si3213263pld.238.2018.04.12.05.01.36
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 12 Apr 2018 05:01:36 -0700 (PDT)
Date: Thu, 12 Apr 2018 14:01:33 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm/page_alloc: don't reserve ZONE_HIGHMEM for
 ZONE_MOVABLE request
Message-ID: <20180412120133.GD23400@dhcp22.suse.cz>
References: <1504672525-17915-1-git-send-email-iamjoonsoo.kim@lge.com>
 <20170914132452.d5klyizce72rhjaa@dhcp22.suse.cz>
 <CAAmzW4NGv7RyCYyokPoj4aR3ySKub4jaBZ3k=pt_YReFbByvsw@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAmzW4NGv7RyCYyokPoj4aR3ySKub4jaBZ3k=pt_YReFbByvsw@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joonsoo Kim <js1304@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@techsingularity.net>, Johannes Weiner <hannes@cmpxchg.org>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Minchan Kim <minchan@kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-api@vger.kernel.org

On Wed 04-04-18 09:24:06, Joonsoo Kim wrote:
> 2017-09-14 22:24 GMT+09:00 Michal Hocko <mhocko@kernel.org>:
> > [Sorry for a later reply]
> >
> > On Wed 06-09-17 13:35:25, Joonsoo Kim wrote:
> >> From: Joonsoo Kim <iamjoonsoo.kim@lge.com>
> >>
> >> Freepage on ZONE_HIGHMEM doesn't work for kernel memory so it's not that
> >> important to reserve.
> >
> > I am still not convinced this is a good idea. I do agree that reserving
> > memory in both HIGHMEM and MOVABLE is just wasting memory but removing
> > the reserve from the highmem as well will result that an oom victim will
> > allocate from lower zones and that might have unexpected side effects.
> 
> Looks like you are confused.
> 
> This patch only affects the situation that ZONE_HIGHMEM and ZONE_MOVABLE is
> used at the same time. In that case, before this patch, ZONE_HIGHMEM has
> reserve for GFP_HIGHMEM | GFP_MOVABLE request, but, with this patch,  no reserve
> in ZONE_HIGHMEM for GFP_HIGHMEM | GFP_MOVABLE request. This perfectly
> matchs with your hope. :)

I have forgot all the details but my vague recollection is that the
concern was that GFP_HIGHUSER_MOVABLE etc. wouldn't keep any reserve in
the highmem zone and so emergency allocations - e.g. those during OOM
will have to fallback to kernel zones and might lead to hard to predict
results. Am I still confused and this will not happen after the patch?
-- 
Michal Hocko
SUSE Labs
