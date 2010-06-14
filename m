Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id 6C8086B01B9
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 14:59:59 -0400 (EDT)
Message-ID: <4C167C19.6030804@redhat.com>
Date: Mon, 14 Jun 2010 14:59:37 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 08/12] vmscan: Setup pagevec as late as possible in shrink_inactive_list()
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-9-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> shrink_inactive_list() sets up a pagevec to release unfreeable pages. It
> uses significant amounts of stack doing this. This patch splits
> shrink_inactive_list() to take the stack usage out of the main path so
> that callers to writepage() do not contain an unused pagevec on the
> stack.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
> Reviewed-by: Johannes Weiner<hannes@cmpxchg.org>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
