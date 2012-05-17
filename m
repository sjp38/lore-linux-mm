Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx115.postini.com [74.125.245.115])
	by kanga.kvack.org (Postfix) with SMTP id 9DB446B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 16:12:51 -0400 (EDT)
Date: Thu, 17 May 2012 16:12:45 -0400 (EDT)
Message-Id: <20120517.161245.2279668542058844372.davem@davemloft.net>
Subject: Re: [PATCH 10/17] netvm: Allow skb allocation to use PFMEMALLOC
 reserves
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337266231-8031-11-git-send-email-mgorman@suse.de>
References: <1337266231-8031-1-git-send-email-mgorman@suse.de>
	<1337266231-8031-11-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, neilb@suse.de, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:50:24 +0100

> Change the skb allocation API to indicate RX usage and use this to fall
> back to the PFMEMALLOC reserve when needed. SKBs allocated from the
> reserve are tagged in skb->pfmemalloc. If an SKB is allocated from
> the reserve and the socket is later found to be unrelated to page
> reclaim, the packet is dropped so that the memory remains available
> for page reclaim. Network protocols are expected to recover from this
> packet loss.
> 
> [davem@davemloft.net: Use static branches, coding style corrections]
> [a.p.zijlstra@chello.nl: Ideas taken from various patches]
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
