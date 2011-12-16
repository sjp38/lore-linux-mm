Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id B7A9F6B004D
	for <linux-mm@kvack.org>; Thu, 15 Dec 2011 22:34:42 -0500 (EST)
Message-ID: <4EEABC4D.7070706@redhat.com>
Date: Thu, 15 Dec 2011 22:34:37 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 06/11] mm: compaction: make isolate_lru_page() filter-aware
 again
References: <1323877293-15401-1-git-send-email-mgorman@suse.de> <1323877293-15401-7-git-send-email-mgorman@suse.de>
In-Reply-To: <1323877293-15401-7-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On 12/14/2011 10:41 AM, Mel Gorman wrote:
> Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
> noted that compaction does not migrate dirty or writeback pages and
> that is was meaningless to pick the page and re-add it to the LRU list.
> This had to be partially reverted because some dirty pages can be
> migrated by compaction without blocking.
>
> This patch updates "mm: compaction: make isolate_lru_page" by skipping
> over pages that migration has no possibility of migrating to minimise
> LRU disruption.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel<riel@redhat.com>

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
