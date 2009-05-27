Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with SMTP id A8C236B005C
	for <linux-mm@kvack.org>; Wed, 27 May 2009 13:32:16 -0400 (EDT)
Message-ID: <4A1D7935.10000@redhat.com>
Date: Wed, 27 May 2009 13:32:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [rfc][patch] swap: virtual swap readahead
References: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
In-Reply-To: <1243436746-2698-1-git-send-email-hannes@cmpxchg.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Hugh Dickins <hugh.dickins@tiscali.co.uk>
List-ID: <linux-mm.kvack.org>

Johannes Weiner wrote:

> This patch makes swap-in base its readaround window on the virtual
> proximity of pages in the faulting VMA, as an indicator for pages
> needed in the near future, while still taking physical locality of
> swap slots into account.
> 
> This has the advantage of reading in big batches when the LRU order
> matches the swap slot order while automatically throttling readahead
> when the system is thrashing and swap slots are no longer nicely
> grouped by LRU order.

This is a nice simple implementation of proper
swapin readahead.  The performance results are
surprisingly good.

I suspect the performance oddity you see with
single-process qsbench might be due to qsbench
having a weird access pattern that just happens
to benefit from getting pages back into memory
in LRU order - not something that I expect to
be common, so not a concern.

> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Hugh Dickins <hugh.dickins@tiscali.co.uk>
> Cc: Rik van Riel <riel@redhat.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
