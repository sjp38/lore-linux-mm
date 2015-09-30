Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f52.google.com (mail-qg0-f52.google.com [209.85.192.52])
	by kanga.kvack.org (Postfix) with ESMTP id A166B6B0038
	for <linux-mm@kvack.org>; Wed, 30 Sep 2015 01:25:47 -0400 (EDT)
Received: by qgx61 with SMTP id 61so26056904qgx.3
        for <linux-mm@kvack.org>; Tue, 29 Sep 2015 22:25:47 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id b94si24715893qge.110.2015.09.29.22.25.46
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 29 Sep 2015 22:25:47 -0700 (PDT)
Date: Tue, 29 Sep 2015 22:28:57 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] mm: fix declarations of nr, delta and
 nr_pagecache_reclaimable
Message-Id: <20150929222857.9f29351f.akpm@linux-foundation.org>
In-Reply-To: <20150930051004.GA13409@gmail.com>
References: <20150927210425.GA20155@gmail.com>
	<20150929160727.ef70acf2e44575e9470a4025@linux-foundation.org>
	<20150930051004.GA13409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandru Moise <00moses.alexander00@gmail.com>
Cc: mgorman@suse.de, vbabka@suse.cz, mhocko@suse.com, js1304@gmail.com, hannes@cmpxchg.org, alexander.h.duyck@redhat.com, sasha.levin@oracle.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Wed, 30 Sep 2015 08:10:04 +0300 Alexandru Moise <00moses.alexander00@gmail.com> wrote:

> > > --- a/mm/vmscan.c
> > > +++ b/mm/vmscan.c
> > > @@ -194,7 +194,7 @@ static bool sane_reclaim(struct scan_control *sc)
> > >  
> > >  static unsigned long zone_reclaimable_pages(struct zone *zone)
> > >  {
> > > -	int nr;
> > > +	unsigned long nr;
> > >  
> > >  	nr = zone_page_state(zone, NR_ACTIVE_FILE) +
> > >  	     zone_page_state(zone, NR_INACTIVE_FILE);
> > 
> > OK.
> > 
> 
> Are you sure? Mel Gorman raised the following issue on patch 1/2:
> 
> https://lkml.org/lkml/2015/9/29/253

__zone_watermark_ok() is very different from zone_reclaimable_pages().

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
