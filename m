Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id DA4CF6B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 10:38:04 -0400 (EDT)
Message-ID: <4F6C8AAF.20807@redhat.com>
Date: Fri, 23 Mar 2012 10:37:35 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm: fix testorder interaction between two kswapd patches
References: <alpine.LSU.2.00.1203230254110.31362@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1203230254110.31362@eggly.anvils>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mel@csn.ul.ie>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org

On 03/23/2012 05:57 AM, Hugh Dickins wrote:
> Adjusting cc715d99e529 "mm: vmscan: forcibly scan highmem if there are
> too many buffer_heads pinning highmem" for -stable reveals that it was
> slightly wrong once on top of fe2c2a106663 "vmscan: reclaim at order 0
> when compaction is enabled", which specifically adds testorder for the
> zone_watermark_ok_safe() test.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>

Acked-by: Rik van Riel <riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
