Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 3DB1F6B0092
	for <linux-mm@kvack.org>; Thu, 17 May 2012 16:13:10 -0400 (EDT)
Date: Thu, 17 May 2012 16:13:04 -0400 (EDT)
Message-Id: <20120517.161304.1765970628771192598.davem@davemloft.net>
Subject: Re: [PATCH 12/17] netvm: Propagate page->pfmemalloc from
 skb_alloc_page to skb
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337266231-8031-13-git-send-email-mgorman@suse.de>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
	<1337266231-8031-13-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:50:26 +0100

> The skb->pfmemalloc flag gets set to true iff during the slab
> allocation of data in __alloc_skb that the the PFMEMALLOC reserves
> were used. If page splitting is used, it is possible that pages will
> be allocated from the PFMEMALLOC reserve without propagating this
> information to the skb. This patch propagates page->pfmemalloc from
> pages allocated for fragments to the skb.
> 
> It works by reintroducing and expanding the skb_alloc_page() API
> to take an skb. If the page was allocated from pfmemalloc reserves,
> it is automatically copied. If the driver allocates the page before
> the skb, it should call skb_propagate_pfmemalloc() after the skb is
> allocated to ensure the flag is copied properly.
> 
> Failure to do so is not critical. The resulting driver may perform
> slower if it is used for swap-over-NBD or swap-over-NFS but it should
> not result in failure.
> 
> [davem@davemloft.net: API rename and consistency]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
