Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id B9E696B00EE
	for <linux-mm@kvack.org>; Tue, 30 Aug 2011 21:10:03 -0400 (EDT)
Message-ID: <4E5D89E3.6020008@redhat.com>
Date: Tue, 30 Aug 2011 21:09:55 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/3] compaction: compact unevictable page
References: <cover.1321112552.git.minchan.kim@gmail.com> <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
In-Reply-To: <8ef02605a7a76b176167d90a285033afa8513326.1321112552.git.minchan.kim@gmail.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>

On 11/12/2011 11:37 AM, Minchan Kim wrote:
> Now compaction doesn't handle mlocked page as it uses __isolate_lru_page
> which doesn't consider unevicatable page. It has been used by just lumpy so
> it was pointless that it isolates unevictable page. But the situation is
> changed. Compaction could handle unevictable page and it can help getting
> big contiguos pages in fragment memory by many pinned page with mlock.
>
> I tested this patch with following scenario.
>
> 1. A : allocate 80% anon pages in system
> 2. B : allocate 20% mlocked page in system
> /* Maybe, mlocked pages are located in low pfn address */
> 3. kill A /* high pfn address are free */
> 4. echo 1>  /proc/sys/vm/compact_memory
>
> old:
>
> compact_blocks_moved 251
> compact_pages_moved 44
>
> new:
>
> compact_blocks_moved 258
> compact_pages_moved 412
>
> CC: Mel Gorman<mgorman@suse.de>
> CC: Johannes Weiner<jweiner@redhat.com>
> CC: Rik van Riel<riel@redhat.com>
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
