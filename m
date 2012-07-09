Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx124.postini.com [74.125.245.124])
	by kanga.kvack.org (Postfix) with SMTP id 3709E6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 15:19:24 -0400 (EDT)
Date: Mon, 9 Jul 2012 21:18:56 +0200
From: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Subject: Re: [PATCH 11/16] netvm: Propagate page->pfmemalloc from
 skb_alloc_page to skb
Message-ID: <20120709191856.GD3515@breakpoint.cc>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-12-git-send-email-mgorman@suse.de>
 <20120626201328.GI6509@breakpoint.cc>
 <20120627084348.GG8271@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120627084348.GG8271@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Wed, Jun 27, 2012 at 09:43:48AM +0100, Mel Gorman wrote:
> > You did not touch all drivers which use alloc_page(s)() like e1000(e). Was
> > this on purpose?
> 
> Yes. The ones I changed were the semi-obvious ones and carried over from
> when the patches were completely out of tree.  As the changelog notes
> it is not critical that these annotation happens and can be fixed on a
> per-driver basis if there are complains about network swapping being slow.
okay, I was just curious why some drivers were updated and others not.

> I can update e1000 if you like but it's not critical
> to do so and in fact getting a bug reporting saying that network swap
> was slow on e1000 would be useful to me in its own way :)
No, leave as it, I was just curious.
One thing: Do you think it makes sense to you introduce
	#define GFP_NET_RX     (GFP_ATOMIC | __GFP_MEMALLOC)

and use it within the receive path instead of GFP_ATOMIC?

Sebastian

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
