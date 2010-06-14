Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id DE8116B01B6
	for <linux-mm@kvack.org>; Mon, 14 Jun 2010 15:25:10 -0400 (EDT)
Message-ID: <4C1681ED.5080502@redhat.com>
Date: Mon, 14 Jun 2010 15:24:29 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 09/12] vmscan: Setup pagevec as late as possible in shrink_page_list()
References: <1276514273-27693-1-git-send-email-mel@csn.ul.ie> <1276514273-27693-10-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1276514273-27693-10-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Dave Chinner <david@fromorbit.com>, Chris Mason <chris.mason@oracle.com>, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Christoph Hellwig <hch@infradead.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>
List-ID: <linux-mm.kvack.org>

On 06/14/2010 07:17 AM, Mel Gorman wrote:
> shrink_page_list() sets up a pagevec to release pages as according as they
> are free. It uses significant amounts of stack on the pagevec. This
> patch adds pages to be freed via pagevec to a linked list which is then
> freed en-masse at the end. This avoids using stack in the main path that
> potentially calls writepage().
>
> Signed-off-by: Mel Gorman<mel@csn.ul.ie>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
