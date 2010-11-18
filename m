Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 668106B0087
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 03:45:11 -0500 (EST)
Date: Thu, 18 Nov 2010 08:44:55 +0000
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 0/8] Use memory compaction instead of lumpy reclaim
	during high-order allocations
Message-ID: <20101118084455.GD8135@csn.ul.ie>
References: <1290010969-26721-1-git-send-email-mel@csn.ul.ie> <20101117154641.51fd7ce5.akpm@linux-foundation.org> <20101118081254.GB8135@csn.ul.ie> <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20101118172627.cf25b83a.kamezawa.hiroyu@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Thu, Nov 18, 2010 at 05:26:27PM +0900, KAMEZAWA Hiroyuki wrote:
> On Thu, 18 Nov 2010 08:12:54 +0000
> Mel Gorman <mel@csn.ul.ie> wrote:
> 
> > > > I'm hoping that this series also removes the
> > > > necessity for the "delete lumpy reclaim" patch from the THP tree.
> > > 
> > > Now I'm sad.  I read all that and was thinking "oh goody, we get to
> > > delete something for once".  But no :(
> > > 
> > > If you can get this stuff to work nicely, why can't we remove lumpy
> > > reclaim?
> > 
> > Ultimately we should be able to. Lumpy reclaim is still there for the
> > !CONFIG_COMPACTION case and to have an option if we find that compaction
> > behaves badly for some reason.
> > 
> 
> Hmm. CONFIG_COMPACTION depends on CONFIG_MMU. lumpy reclaim will be for NOMMU,
> finally ?
> 

Also true. As it is, lumpy reclaim is still there but it's never called
if CONFIG_COMPACTION is set so it's already side-lined.

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
