Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 9E8736B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 19:14:36 -0400 (EDT)
Date: Mon, 22 Jun 2009 16:15:02 -0700 (PDT)
Message-Id: <20090622.161502.74508182.davem@davemloft.net>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
 from DCCP
From: David Miller <davem@davemloft.net>
In-Reply-To: <1245685414-8979-4-git-send-email-mel@csn.ul.ie>
References: <1245685414-8979-1-git-send-email-mel@csn.ul.ie>
	<1245685414-8979-4-git-send-email-mel@csn.ul.ie>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: mel@csn.ul.ie
Cc: akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

From: Mel Gorman <mel@csn.ul.ie>
Date: Mon, 22 Jun 2009 16:43:34 +0100

> The DCCP protocol tries to allocate some large hash tables during
> initialisation using the largest size possible.  This can be larger than
> what the page allocator can provide so it prints a warning. However, the
> caller is able to handle the situation so this patch suppresses the warning.
> 
> Signed-off-by: Mel Gorman <mel@csn.ul.ie>

It's probably much more appropriate to make this stuff use
alloc_large_system_hash(), like TCP does (see net/ipv4/tcp.c
tcp_init()).

All of this complicated DCCP hash table size computation code will
simply disappear.  And it'll fix the warning too :-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
