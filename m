Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 275DE6B01F1
	for <linux-mm@kvack.org>; Mon, 16 Aug 2010 10:48:27 -0400 (EDT)
Message-ID: <4C694F9A.3030106@redhat.com>
Date: Mon, 16 Aug 2010 10:47:54 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] mm: page allocator: Calculate a better estimate of
 NR_FREE_PAGES when memory is low and kswapd is awake
References: <1281951733-29466-1-git-send-email-mel@csn.ul.ie> <1281951733-29466-3-git-send-email-mel@csn.ul.ie> <20100816094350.GH19797@csn.ul.ie>
In-Reply-To: <20100816094350.GH19797@csn.ul.ie>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Mel Gorman <mel@csn.ul.ie>
Cc: linux-mm@kvack.org, Nick Piggin <npiggin@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

On 08/16/2010 05:43 AM, Mel Gorman wrote:
> On Mon, Aug 16, 2010 at 10:42:12AM +0100, Mel Gorman wrote:
>> Ordinarily watermark checks are made based on the vmstat NR_FREE_PAGES as
>> it is cheaper than scanning a number of lists. To avoid synchronization
>> overhead, counter deltas are maintained on a per-cpu basis and drained both
>> periodically and when the delta is above a threshold. On large CPU systems,
>> the difference between the estimated and real value of NR_FREE_PAGES can be
>> very high. If the system is under both load and low memory, it's possible
>> for watermarks to be breached. In extreme cases, the number of free pages
>> can drop to 0 leading to the possibility of system livelock.
>>
>> This patch introduces zone_nr_free_pages() to take a slightly more accurate
>> estimate of NR_FREE_PAGES while kswapd is awake.  The estimate is not perfect
>> and may result in cache line bounces but is expected to be lighter than the
>> IPI calls necessary to continually drain the per-cpu counters while kswapd
>> is awake.
>>
>> Signed-off-by: Mel Gorman<mel@csn.ul.ie>
>
> And the second I sent this, I realised I had sent a slightly old version
> that missed a compile-fix :(

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
