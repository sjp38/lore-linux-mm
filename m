Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 19D4D6B0082
	for <linux-mm@kvack.org>; Thu, 17 May 2012 16:15:22 -0400 (EDT)
Date: Thu, 17 May 2012 16:14:09 -0400 (EDT)
Message-Id: <20120517.161409.1978274725713298734.davem@davemloft.net>
Subject: Re: [PATCH 01/12] netvm: Prevent a stream-specific deadlock
From: David Miller <davem@davemloft.net>
In-Reply-To: <1337266285-8102-2-git-send-email-mgorman@suse.de>
References: <1337266285-8102-1-git-send-email-mgorman@suse.de>
	<1337266285-8102-2-git-send-email-mgorman@suse.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: mgorman@suse.de
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, netdev@vger.kernel.org, linux-nfs@vger.kernel.org, linux-kernel@vger.kernel.org, Trond.Myklebust@netapp.com, neilb@suse.de, hch@infradead.org, a.p.zijlstra@chello.nl, michaelc@cs.wisc.edu, emunson@mgebm.net

From: Mel Gorman <mgorman@suse.de>
Date: Thu, 17 May 2012 15:51:14 +0100

> It could happen that all !SOCK_MEMALLOC sockets have buffered so
> much data that we're over the global rmem limit. This will prevent
> SOCK_MEMALLOC buffers from receiving data, which will prevent userspace
> from running, which is needed to reduce the buffered data.
> 
> Fix this by exempting the SOCK_MEMALLOC sockets from the rmem limit.
> Once this change it applied, it is important that sockets that set
> SOCK_MEMALLOC do not clear the flag until the socket is being torn down.
> If this happens, a warning is generated and the tokens reclaimed to
> avoid accounting errors until the bug is fixed.
> 
> [davem@davemloft.net: Warning about clearing SOCK_MEMALLOC]
> Signed-off-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
> Signed-off-by: Mel Gorman <mgorman@suse.de>

Acked-by: David S. Miller <davem@davemloft.net>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
