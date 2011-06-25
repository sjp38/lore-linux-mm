Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 59153900117
	for <linux-mm@kvack.org>; Sat, 25 Jun 2011 17:42:21 -0400 (EDT)
Message-ID: <4E065630.2070407@redhat.com>
Date: Sat, 25 Jun 2011 17:42:08 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/4] mm: vmscan: Evaluate the watermarks against the correct
 classzone
References: <1308926697-22475-1-git-send-email-mgorman@suse.de> <1308926697-22475-4-git-send-email-mgorman@suse.de>
In-Reply-To: <1308926697-22475-4-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, =?UTF-8?B?UMOhZHJhaWcgQnJh?= =?UTF-8?B?ZHk=?= <P@draigBrady.com>, James Bottomley <James.Bottomley@HansenPartnership.com>, Colin King <colin.king@canonical.com>, Minchan Kim <minchan.kim@gmail.com>, Andrew Lutomirski <luto@mit.edu>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm <linux-mm@kvack.org>, linux-kernel <linux-kernel@vger.kernel.org>

On 06/24/2011 10:44 AM, Mel Gorman wrote:
> When deciding if kswapd is sleeping prematurely, the classzone is
> taken into account but this is different to what balance_pgdat() and
> the allocator are doing. Specifically, the DMA zone will be checked
> based on the classzone used when waking kswapd which could be for a
> GFP_KERNEL or GFP_HIGHMEM request. The lowmem reserve limit kicks in,
> the watermark is not met and kswapd thinks its sleeping prematurely
> keeping kswapd awake in error.
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
