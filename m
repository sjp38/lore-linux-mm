Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id D59D06B004D
	for <linux-mm@kvack.org>; Tue, 17 Nov 2009 05:15:28 -0500 (EST)
Date: Tue, 17 Nov 2009 05:15:26 -0500
From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 0/7] Kill PF_MEMALLOC abuse
Message-ID: <20091117101526.GA4797@infradead.org>
References: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20091117161551.3DD4.A69D9226@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On Tue, Nov 17, 2009 at 04:16:04PM +0900, KOSAKI Motohiro wrote:
> Some subsystem paid attention (1) only, and start to use PF_MEMALLOC abuse.
> But, the fact is, PF_MEMALLOC is the promise of "I have lots freeable memory.
> if I allocate few memory, I can return more much meory to the system!".
> Non MM subsystem must not use PF_MEMALLOC. Memory reclaim
> need few memory, anyone must not prevent it. Otherwise the system cause
> mysterious hang-up and/or OOM Killer invokation.

And that's exactly the promises xfsbufd gives.  It writes out dirty
metadata buffers and will free lots of memory if you kick it. 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
