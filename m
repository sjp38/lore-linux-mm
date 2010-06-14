Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 674F96B01DA
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 13:38:08 -0400 (EDT)
Message-ID: <4C165D58.9090609@redhat.com>
Date: Mon, 14 Jun 2010 12:48:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 03/12] tracing, vmscan: Add trace event when a page is
 written
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-4-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-4-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> This patch adds a trace event for when page reclaim queues a page for IO and
> records whether it is synchronous or asynchronous. Excessive synchronous
> IO for a process can result in noticeable stalls during direct reclaim.
> Excessive IO from page reclaim may indicate that the system is seriously
> under provisioned for the amount of dirty pages that exist.
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
