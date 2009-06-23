Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 1D3406B004F
	for <linux-mm@kvack.org>; Tue, 23 Jun 2009 04:47:18 -0400 (EDT)
Date: Tue, 23 Jun 2009 09:48:43 +0100
From: Mel Gorman <mel@csn.ul.ie>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
	from DCCP
Message-ID: <20090623084843.GB9003@csn.ul.ie>
References: <1245685414-8979-1-git-send-email-mel@csn.ul.ie> <1245685414-8979-4-git-send-email-mel@csn.ul.ie> <20090622.161502.74508182.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Disposition: inline
In-Reply-To: <20090622.161502.74508182.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

On Mon, Jun 22, 2009 at 04:15:02PM -0700, David Miller wrote:
> From: Mel Gorman <mel@csn.ul.ie>
> Date: Mon, 22 Jun 2009 16:43:34 +0100
> 
> > The DCCP protocol tries to allocate some large hash tables during
> > initialisation using the largest size possible.  This can be larger than
> > what the page allocator can provide so it prints a warning. However, the
> > caller is able to handle the situation so this patch suppresses the warning.
> > 
> > Signed-off-by: Mel Gorman <mel@csn.ul.ie>
> 
> It's probably much more appropriate to make this stuff use
> alloc_large_system_hash(), like TCP does (see net/ipv4/tcp.c
> tcp_init()).
> 

I agree. In another mail I asked why it wasn't used. I guessed it might be
because of the __init tag but nothing stops that being deleted. It should
not take significant effort to make it usable by DCCP.

> All of this complicated DCCP hash table size computation code will
> simply disappear.  And it'll fix the warning too :-)
>  

It would be my preferred option :)

-- 
Mel Gorman
Part-time Phd Student                          Linux Technology Center
University of Limerick                         IBM Dublin Software Lab

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
