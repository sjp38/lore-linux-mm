Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta8.messagelabs.com (mail6.bemta8.messagelabs.com [216.82.243.55])
	by kanga.kvack.org (Postfix) with ESMTP id 2C9766B0012
	for <linux-mm@kvack.org>; Tue, 31 May 2011 16:48:55 -0400 (EDT)
Message-ID: <4DE5542B.2040700@redhat.com>
Date: Tue, 31 May 2011 16:48:43 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 01/10] Make clear description of isolate/putback functions
References: <cover.1306689214.git.minchan.kim@gmail.com> <5f9f6c96ccb344c4ca0dd9c1f06bd21db93fda51.1306689214.git.minchan.kim@gmail.com>
In-Reply-To: <5f9f6c96ccb344c4ca0dd9c1f06bd21db93fda51.1306689214.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mgorman@suse.de>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On 05/29/2011 02:13 PM, Minchan Kim wrote:
> Commonly, putback_lru_page is used with isolated_lru_page.
> The isolated_lru_page picks the page in middle of LRU and
> putback_lru_page insert the lru in head of LRU.
> It means it could make LRU churning so we have to be very careful.
> Let's clear description of isolate/putback functions.
>
> Cc: Mel Gorman<mgorman@suse.de>
> Cc: Rik van Riel<riel@redhat.com>
> Cc: Andrea Arcangeli<aarcange@redhat.com>
> Reviewed-by: KAMEZAWA Hiroyuki<kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Johannes Weiner<hannes@cmpxchg.org>
> Reviewed-by: KOSAKI Motohiro<kosaki.motohiro@jp.fujitsu.com>
> Signed-off-by: Minchan Kim<minchan.kim@gmail.com>

Reviewed-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
