Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 8C2EF6B0035
	for <linux-mm@kvack.org>; Mon, 11 Aug 2014 08:12:46 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id n3so4113142wiv.11
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 05:12:46 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id dw12si26085885wjb.138.2014.08.11.05.12.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 11 Aug 2014 05:12:45 -0700 (PDT)
Date: Mon, 11 Aug 2014 13:12:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 6/6] mm: page_alloc: Reduce cost of the fair zone
 allocation policy
Message-ID: <20140811121241.GD7970@suse.de>
References: <1404893588-21371-1-git-send-email-mgorman@suse.de>
 <1404893588-21371-7-git-send-email-mgorman@suse.de>
 <53E4EC53.1050904@suse.cz>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <53E4EC53.1050904@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux Kernel <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Linux-FSDevel <linux-fsdevel@vger.kernel.org>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Aug 08, 2014 at 05:27:15PM +0200, Vlastimil Babka wrote:
> On 07/09/2014 10:13 AM, Mel Gorman wrote:
> > --- a/mm/page_alloc.c
> > +++ b/mm/page_alloc.c
> > @@ -1604,6 +1604,9 @@ again:
> >  	}
> >  
> >  	__mod_zone_page_state(zone, NR_ALLOC_BATCH, -(1 << order));
> 
> This can underflow zero, right?
> 

Yes, because of per-cpu accounting drift.

> > +	if (zone_page_state(zone, NR_ALLOC_BATCH) == 0 &&
> 
> AFAICS, zone_page_state will correct negative values to zero only for
> CONFIG_SMP. Won't this check be broken on !CONFIG_SMP?
> 

On !CONFIG_SMP how can there be per-cpu accounting drift that would make
that counter negative?

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
