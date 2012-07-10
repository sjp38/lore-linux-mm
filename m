Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx203.postini.com [74.125.245.203])
	by kanga.kvack.org (Postfix) with SMTP id 98DFB6B006C
	for <linux-mm@kvack.org>; Tue, 10 Jul 2012 07:12:46 -0400 (EDT)
Date: Tue, 10 Jul 2012 12:12:42 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 11/16] netvm: Propagate page->pfmemalloc from
 skb_alloc_page to skb
Message-ID: <20120710111242.GD14154@suse.de>
References: <1340375443-22455-1-git-send-email-mgorman@suse.de>
 <1340375443-22455-12-git-send-email-mgorman@suse.de>
 <20120626201328.GI6509@breakpoint.cc>
 <20120627084348.GG8271@suse.de>
 <20120709191856.GD3515@breakpoint.cc>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120709191856.GD3515@breakpoint.cc>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sebastian Andrzej Siewior <sebastian@breakpoint.cc>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux-MM <linux-mm@kvack.org>, Linux-Netdev <netdev@vger.kernel.org>, LKML <linux-kernel@vger.kernel.org>, David Miller <davem@davemloft.net>, Neil Brown <neilb@suse.de>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Mike Christie <michaelc@cs.wisc.edu>, Eric B Munson <emunson@mgebm.net>, Eric Dumazet <eric.dumazet@gmail.com>

On Mon, Jul 09, 2012 at 09:18:56PM +0200, Sebastian Andrzej Siewior wrote:
> 
> > I can update e1000 if you like but it's not critical
> > to do so and in fact getting a bug reporting saying that network swap
> > was slow on e1000 would be useful to me in its own way :)
> No, leave as it, I was just curious.
> One thing: Do you think it makes sense to you introduce
> 	#define GFP_NET_RX     (GFP_ATOMIC | __GFP_MEMALLOC)
> 
> and use it within the receive path instead of GFP_ATOMIC?
> 

For now, I'd prefer to keep the __GFP_MEMALLOC flag at the different
callsites because it forces people to think about what it means.  I fear
that GFP_NET_RX may be too easy to misuse without thinking about what the
consequences are.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
