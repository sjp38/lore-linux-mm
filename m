Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 6F26A600068
	for <linux-mm@kvack.org>; Mon,  4 Jan 2010 09:05:04 -0500 (EST)
Message-ID: <4B41F572.3080406@redhat.com>
Date: Mon, 04 Jan 2010 09:04:34 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] page allocator: Reduce fragmentation in buddy allocator
 by	adding buddies that are merging to the tail of the free lists
References: <20100104135545.GC6373@csn.ul.ie>
In-Reply-To: <20100104135545.GC6373@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: Andrew Morton <akpm@linux-foundation.org>, Corrado Zoccolo <czoccolo@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On 01/04/2010 08:55 AM, Mel Gorman wrote:
> From: Corrado Zoccolo<czoccolo@gmail.com>
>
> In order to reduce fragmentation, this patch classifies freed pages in
> two groups according to their probability of being part of a high order
> merge. Pages belonging to a compound whose next-highest buddy is free are
> more likely to be part of a high order merge in the near future, so they
> will be added at the tail of the freelist. The remaining pages are put at
> the front of the freelist.

> [mel@csn.ul.ie: Tested, reworked for less branches]
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
