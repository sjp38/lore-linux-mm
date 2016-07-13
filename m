Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id BA2B66B0005
	for <linux-mm@kvack.org>; Wed, 13 Jul 2016 08:29:01 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id l89so32049366lfi.3
        for <linux-mm@kvack.org>; Wed, 13 Jul 2016 05:29:01 -0700 (PDT)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id p125si1159535wmp.76.2016.07.13.05.29.00
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 13 Jul 2016 05:29:00 -0700 (PDT)
Date: Wed, 13 Jul 2016 08:28:48 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 12/34] mm: vmscan: do not reclaim from kswapd if there is
 any eligible zone
Message-ID: <20160713122848.GA9905@cmpxchg.org>
References: <1467970510-21195-1-git-send-email-mgorman@techsingularity.net>
 <1467970510-21195-13-git-send-email-mgorman@techsingularity.net>
 <20160712142909.GF5881@cmpxchg.org>
 <20160713084742.GG9806@techsingularity.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20160713084742.GG9806@techsingularity.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@techsingularity.net>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Rik van Riel <riel@surriel.com>, Vlastimil Babka <vbabka@suse.cz>, Minchan Kim <minchan@kernel.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, LKML <linux-kernel@vger.kernel.org>

On Wed, Jul 13, 2016 at 09:47:42AM +0100, Mel Gorman wrote:
> On Tue, Jul 12, 2016 at 10:29:09AM -0400, Johannes Weiner wrote:
> > > +		/*
> > > +		 * If the number of buffer_heads in the machine exceeds the
> > > +		 * maximum allowed level then reclaim from all zones. This is
> > > +		 * not specific to highmem as highmem may not exist but it is
> > > +		 * it is expected that buffer_heads are stripped in writeback.
> > 
> > The mention of highmem in this comment make only sense within the
> > context of this diff; it'll be pretty confusing in the standalone
> > code.
> > 
> > Also, double "it is" :)
> 
> Is this any better?

Yes, this is great! Thank you.

> Note that it's marked as a fix to a later patch to reduce collisions in
> mmotm. It's not a bisection risk so I saw little need to cause
> unnecessary conflicts for Andrew.

That seems completely reasonable to me.

> ---8<---
> mm, vmscan: Have kswapd reclaim from all zones if reclaiming and buffer_heads_over_limit -fix
> 
> Johannes reported that the comment about buffer_heads_over_limit in
> balance_pgdat only made sense in the context of the patch. This
> patch clarifies the reasoning and how it applies to 32 and 64 bit
> systems.
> 
> This is a fix to the mmotm patch
> mm-vmscan-have-kswapd-reclaim-from-all-zones-if-reclaiming-and-buffer_heads_over_limit.patch
> 
> Suggested-by: Johannes Weiner <hannes@cmpxchg.org>
> Signed-off-by: Mel Gorman <mgorman@techsingularity.net>

Acked-by: Johannes Weiner <hannes@cmpxchg.org>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
