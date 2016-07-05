Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f71.google.com (mail-wm0-f71.google.com [74.125.82.71])
	by kanga.kvack.org (Postfix) with ESMTP id CE77A6B0005
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 06:40:23 -0400 (EDT)
Received: by mail-wm0-f71.google.com with SMTP id r190so84481841wmr.0
        for <linux-mm@kvack.org>; Tue, 05 Jul 2016 03:40:23 -0700 (PDT)
Received: from outbound-smtp06.blacknight.com (outbound-smtp06.blacknight.com. [81.17.249.39])
        by mx.google.com with ESMTPS id h142si3275362wmd.3.2016.07.05.03.40.22
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Jul 2016 03:40:22 -0700 (PDT)
Received: from mail.blacknight.com (pemlinmail06.blacknight.ie [81.17.255.152])
	by outbound-smtp06.blacknight.com (Postfix) with ESMTPS id 6DC3F98C3A
	for <linux-mm@kvack.org>; Tue,  5 Jul 2016 10:40:22 +0000 (UTC)
Date: Tue, 5 Jul 2016 11:40:20 +0100
From: Mel Gorman <mgorman@techsingularity.net>
Subject: Re: [PATCH 12/31] mm, vmscan: make shrink_node decisions more
 node-centric
Message-ID: <20160705104020.GI11498@techsingularity.net>
References: <1467403299-25786-1-git-send-email-mgorman@techsingularity.net>
 <1467403299-25786-13-git-send-email-mgorman@techsingularity.net>
 <20160705062436.GE28164@bbox>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20160705062436.GE28164@bbox>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>

On Tue, Jul 05, 2016 at 03:24:36PM +0900, Minchan Kim wrote:
> > diff --git a/mm/vmscan.c b/mm/vmscan.c
> > index 2f898ba2ee2e..b8e0f76b6e00 100644
> > --- a/mm/vmscan.c
> > +++ b/mm/vmscan.c
> > @@ -2226,10 +2226,11 @@ static inline void init_tlb_ubc(void)
> >  /*
> >   * This is a basic per-zone page freer.  Used by both kswapd and direct reclaim.
>          
>                       per-node freer
> 

Fixed.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
