Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B5AA96B01CA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 12:56:09 -0400 (EDT)
Message-ID: <4C165D04.9020400@redhat.com>
Date: Mon, 14 Jun 2010 12:47:00 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 02/12] tracing, vmscan: Add trace events for LRU page
 isolation
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-3-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-3-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> This patch adds an event for when pages are isolated en-masse from the
> LRU lists. This event augments the information available on LRU traffic
> and can be used to evaluate lumpy reclaim.
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
