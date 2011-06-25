Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 32BC0900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 17:40:39 -0400 (EDT)
Message-ID: <4E0655C8.7080908@redhat.com>
Date: Sat, 25 Jun 2011 17:40:24 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/4] mm: vmscan: Do not apply pressure to slab if we are
 not applying pressure to zone
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-3-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-3-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?UMOhZHJhaWcgQnJh?= =?UTF-8?B?ZHk=?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 06/24/2011 10:44 AM, Mel Gorman wrote:
> During allocator-intensive workloads, kswapd will be woken frequently
> causing free memory to oscillate between the high and min watermark.
> This is expected behaviour.
>
> When kswapd applies pressure to zones during node balancing, it checks
> if the zone is above a high+balance_gap threshold. If it is, it does
> not apply pressure but it unconditionally shrinks slab on a global
> basis which is excessive. In the event kswapd is being kept awake due to
> a high small unreclaimable zone, it skips zone shrinking but still
> calls shrink_slab().
>
> Once pressure has been applied, the check for zone being unreclaimable
> is being made before the check is made if all_unreclaimable should be
> set. This miss of unreclaimable can cause has_under_min_watermark_zone
> to be set due to an unreclaimable zone preventing kswapd backing off
> on congestion_wait().
>
> Reported-and-tested-by: PA!draig Brady<P@draigBrady.com>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
