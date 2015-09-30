Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f173.google.com (mail-wi0-f173.google.com [209.85.212.173])
	by kanga.kvack.org (Postfix) with ESMTP id 2DC6E6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:13:05 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so179881256wic.0
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:13:04 -0700 (PDT)
Received: from mail-wi0-x244.google.com (mail-wi0-x244.google.com. [2a00:1450:400c:c05::244])
        by mx.google.com with ESMTPS id h3si34106659wjw.15.2015.09.29.22.13.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 22:13:04 -0700 (PDT)
Received: by wiku15 with SMTP id u15so6791731wik.1
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:13:03 -0700 (PDT)
Date: Wed, 30 Sep 2015 08:10:04 +0300
From: Alexandru Moise <00moses.alexander00@gmail.com>
Subject: Re: [PATCH 2/2] mm: fix declarations of nr, delta and
 nr_pagecache_reclaimable
Message-ID: <20150930051004.GA13409@gmail.com>
References: <20150927210425.GA20155@gmail.com>
 <20150929160727.ef70acf2e44575e9470a4025@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20150929160727.ef70acf2e44575e9470a4025@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -194,7 +194,7 @@ static bool sane_reclaim(struct scan_control *sc)
> >  
> >  static unsigned long zone_reclaimable_pages(struct zone *zone)
> >  {
> > -	int nr;
> > +	unsigned long nr;
> >  
> >  	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> >  	     zone_page_state(zone, NR_INACTIVE_FILE);
> 
> OK.
> 

Are you sure? Mel Gorman raised the following issue on patch 1/2:

https://lkml.org/lkml/2015/9/29/253

Thanks for the review.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
