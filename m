Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 8ACA36B004F
	for <linux-mm@kvack.org>; Mon, 22 Jun 2009 22:39:09 -0400 (EDT)
Date: Mon, 22 Jun 2009 23:39:36 -0300
From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 3/3] net-dccp: Suppress warning about large allocations
	from DCCP
Message-ID: <20090623023936.GA2721@ghostprotocols.net>
References: <1245685414-8979-1-git-send-email-mel@csn.ul.ie> <1245685414-8979-4-git-send-email-mel@csn.ul.ie> <20090622.161502.74508182.davem@davemloft.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20090622.161502.74508182.davem@davemloft.net>
Sender: owner-linux-mm@kvack.org
To: David Miller <davem@davemloft.net>
Cc: mel@csn.ul.ie, akpm@linux-foundation.org, mingo@elte.hu, linux-kernel@vger.kernel.org, linux-mm@kvack.org, htd@fancy-poultry.org
List-ID: <linux-mm.kvack.org>

Em Mon, Jun 22, 2009 at 04:15:02PM -0700, David Miller escreveu:
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
> All of this complicated DCCP hash table size computation code will
> simply disappear.  And it'll fix the warning too :-)

He mentioned that in the conversation that lead to this new patch
series, problem is that alloc_large_system_hash is __init, so when you
try to load dccp.ko it will not be available.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
