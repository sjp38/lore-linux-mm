Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1E3D36B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 14:50:41 -0500 (EST)
Date: Thu, 18 Nov 2010 11:49:28 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
 during high-order allocations
Message-Id: <20101118114928.ecb2d6b0.akpm@linux-foundation.org>
In-Reply-To: <20101118092044.GE8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie>
	<20101117154641.51fd7ce5.akpm@linux-foundation.org>
	<20101118081254.GB8135@csn.ul.ie>
	<20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com>
	<20101118083828.GA24635@cmpxchg.org>
	<20101118092044.GE8135@csn.ul.ie>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, 18 Nov 2010 09:20:44 +0000
Mel Gorman <mel@csn.ul.ie> wrote:

> > It's because migration depends on MMU.  But we should be able to make
> > a NOMMU version of migration that just does page cache, which is all
> > that is reclaimable on NOMMU anyway.
> > 
> 
> Conceivably, but I see little problem leaving them with lumpy reclaim.

I see a really big problem: we'll need to maintain lumpy reclaim for
ever!

We keep on piling in more and more stuff, we're getting less sure that
the old stuff is still effective.  It's becoming more and more
important to move some of our attention over to simplification, and
to rejustification of earlier decisions.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
