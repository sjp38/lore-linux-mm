Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id 637976B0088
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 20:08:42 -0500 (EST)
Date: Wed, 8 Dec 2010 17:08:38 -0800
From: Simon Kirby <sim@hostway.ca>
Subject: Re: [patch] mm: skip rebalance of hopeless zones
Message-ID: <20101209010838.GA11758@hostway.ca>
References: <1291821419-11213-1-git-send-email-hannes@cmpxchg.org> <20101209003621.GB3796@hostway.ca> <4D00277F.9040000@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4D00277F.9040000@redhat.com>
Sender: owner-linux-mm@kvack.org
To: Rik van Riel <riel@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mel@csn.ul.ie>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 07:49:03PM -0500, Rik van Riel wrote:

> On 12/08/2010 07:36 PM, Simon Kirby wrote:
>
>> Mel Gorman posted a similar patch to yours, but the logic is instead to
>> consider order>0 balancing sufficient when there are other balanced zones
>> totalling at least 25% of pages on this node.  This would probably fix
>> your case as well.
>
> Mel's patch addresses something very different and is unlikely
> to fix the problem this patch addresses.

Ok, I see they're quite separate.

Johannes' patch solves the problem of trying to balance a tiny Normal
zone which happens to be full of unclaimable slab pages by giving up in
this hopeless case, regardless of order.

Mel's patch solves the problem of fighting allocations causing an
order>0 imbalance in the small Normal zone which happens to be full of
reclaimable pages by giving up in this not-worth-bothering case.

The key difference is that Johannes' patch has no condition on order, so
Mel's patch probably would help (though not for intended reasons) in the
order != 0 case, and probably not in the order=0 case.

Simon-

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
