Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id D155E6B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 10:05:52 -0400 (EDT)
Message-ID: <4C694552.1090107@redhat.com>
Date: Mon, 16 Aug 2010 10:04:02 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/3] mm: page allocator: Update free page counters after
 pages are placed on the free list
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
In-Reply-To: <1281951733-29466-2-git-send-email-mel@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 08/16/2010 05:42 AM, Mel Gorman wrote:
> When allocating a page, the system uses NR_FREE_PAGES counters to determine
> if watermarks would remain intact after the allocation was made. This
> check is made without interrupts disabled or the zone lock held and so is
> race-prone by nature. Unfortunately, when pages are being freed in batch,
> the counters are updated before the pages are added on the list. During this
> window, the counters are misleading as the pages do not exist yet. When
> under significant pressure on systems with large numbers of CPUs, it's
> possible for processes to make progress even though they should have been
> stalled. This is particularly problematic if a number of the processes are
> using GFP_ATOMIC as the min watermark can be accidentally breached and in
> extreme cases, the system can livelock.
>
> This patch updates the counters after the pages have been added to the
> list. This makes the allocator more cautious with respect to preserving
> the watermarks and mitigates livelock possibilities.
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
