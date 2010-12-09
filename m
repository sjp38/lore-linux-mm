Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id C009D6B008A
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 09:46:57 -0500 (EST)
Date: Thu, 9 Dec 2010 14:46:32 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101209144632.GF20133@csn.ul.ie>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca> <20101208172324.d45911f4.akpm@linux-foundation.org> <AANLkTi=3WFrrhbrRUi986KCaMknUeXGsb8Lq6O8K4RMd@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <AANLkTi=3WFrrhbrRUi986KCaMknUeXGsb8Lq6O8K4RMd@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
To: Pekka Enberg <penberg@kernel.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Simon Kirby <sim@hostway.ca>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, Christoph Lameter <cl@linux.com>, David Rientjes <rientjes@google.com>, Nick Piggin <npiggin@suse.de>
List-ID: <linux-mm.kvack.org>

On Thu, Dec 09, 2010 at 10:55:10AM +0200, Pekka Enberg wrote:
> On Thu, Dec 9, 2010 at 3:23 AM, Andrew Morton <akpm@linux-foundation.org> wrote:
> > This problem would have got worse when slub came along doing its stupid
> > unnecessary high-order allocations.
> 
> Stupid, maybe but not unnecessary because they're a performance
> improvement on large CPU systems (needed because of current SLUB
> design). We're scaling the allocation order based on number of CPUs
> but maybe we could shrink it even more.
> 

It's conceivable that the GFP_NOKSWAPD patch needs to be taken from the
THP series and applied to slub but only when slub is ruled out as the
only source of the problem. Right now, it looks like forking workloads
are suffering which is unrelated to slub.

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
