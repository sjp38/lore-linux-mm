Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with SMTP id 41D586B01B8
	for <linux-mm@kvack.org>; Tue, 29 Jun 2010 11:15:12 -0400 (EDT)
Date: Tue, 29 Jun 2010 10:14:35 -0500 (CDT)
From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: [PATCH 2/2] vmscan: don't subtraction of unsined 
In-Reply-To: <20100628101802.386A.A69D9226@jp.fujitsu.com>
Message-ID: <alpine.DEB.2.00.1006280521190.8725@router.home>
References: <20100625202126.806A.A69D9226@jp.fujitsu.com> <alpine.DEB.2.00.1006250912380.18900@router.home> <20100628101802.386A.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Mon, 28 Jun 2010, KOSAKI Motohiro wrote:

> It's unsigned. negative mean very big value. so
>
> "zone_page_state(zone, NR_SLAB_RECLAIMABLE) > slab_reclaimable - nr_pages)" will
> be evaluated false.

There were some suggestions on how to address this later in the patch.

> ok, your mysterious 'order' parameter (as pointed [1/2]) almostly prevent this case.
> because passing 'order' makes very heavy slab pressure and it avoid negative occur.
>
> but unnaturall coding style can make confusing to reviewers. ya, it's not
> big issue. but I also don't find no fixing reason.

This is not a coding issue but one of logic. The order parameter is
mysterious to me too. So is the lru_pages logic.

> > The comparison could be a problem here. So
> >
> > 			zone_page_state(zone, NR_SLAB_RECLAIMABLE) + nr_pages >
> > 				slab_reclaimable
> >
> > ?
>
> My patch take the same thing. but It avoided two line comparision.
> Do you mean you like this style? (personally, I don't). If so, I'll
> repost this patch.

Yes. I also do not like long cryptic names for local variables.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
