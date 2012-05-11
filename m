Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx130.postini.com [74.125.245.130])
	by kanga.kvack.org (Postfix) with SMTP id 33E618D0001
	for <linux-mm@kvack.org>; Fri, 11 May 2012 10:46:32 -0400 (EDT)
Date: Fri, 11 May 2012 15:46:20 +0100
From: Mel Gorman <mgorman@suse.de>
Subject: Re: [PATCH 12/17] netvm: Propagate page->pfmemalloc from
 netdev_alloc_page to skb
Message-ID: <20120511144620.GT11435@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
 <1336657510-24378-13-git-send-email-mgorman@suse.de>
 <20120511.010109.1698578316660207883.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20120511.010109.1698578316660207883.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

On Fri, May 11, 2012 at 01:01:09AM -0400, David Miller wrote:
> From: Mel Gorman <mgorman@suse.de>
> Date: Thu, 10 May 2012 14:45:05 +0100
> 
> > +/**
> > + *	propagate_pfmemalloc_skb - Propagate pfmemalloc if skb is allocated after RX page
> > + *	@page: The page that was allocated from netdev_alloc_page
> > + *	@skb: The skb that may need pfmemalloc set
> > + */
> > +static inline void propagate_pfmemalloc_skb(struct page *page,
> > +						struct sk_buff *skb)
> 
> Please use consistent prefixes in the names for new interfaces.
> 

Understood.

> This one should probably be named "skb_propagate_pfmemalloc()" and
> go into skbuff.h since it needs no knowledge of netdevices.
> 

I used a netdev prefix and placed it in skbuff.h which was stupid. The
screw-up was because I was partially reverting a patch that deleted
netdev_alloc_page but I didn't need any device information so the naming
was poor. I renamed netdev_alloc_page to skb_alloc_page and will fix up
the documentation appropriately.

Thanks.

-- 
Mel Gorman
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
