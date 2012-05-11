Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 27EAA6B004D
	for <linux-mm@kvack.org>; Fri, 11 May 2012 01:01:17 -0400 (EDT)
Date: Fri, 11 May 2012 01:01:09 -0400 (EDT)
Message-Id: <20120511.010109.1698578316660207883.davem@davemloft.net>
Subject: Re: [PATCH 12/17] netvm: Propagate page->pfmemalloc from
 netdev_alloc_page to skb
From: David Miller <davem@davemloft.net>
In-Reply-To: <1336657510-24378-13-git-send-email-mgorman@suse.de>
References: <1336657510-24378-1-git-send-email-mgorman@suse.de>
	<1336657510-24378-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 10 May 2012 14:45:05 +0100

> +/**
> + *	propagate_pfmemalloc_skb - Propagate pfmemalloc if skb is allocated after RX page
> + *	@page: The page that was allocated from netdev_alloc_page
> + *	@skb: The skb that may need pfmemalloc set
> + */
> +static inline void propagate_pfmemalloc_skb(struct page *page,
> +						struct sk_buff *skb)

Please use consistent prefixes in the names for new interfaces.

This one should probably be named "skb_propagate_pfmemalloc()" and
go into skbuff.h since it needs no knowledge of netdevices.

In fact all of these routines are about propagation of attributes
into SKBs, irregardless of any netdevice details.

Therefore they should probably all be named skb_*() and go into
skbuff.h

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
