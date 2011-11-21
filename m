Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id A99DC6B0070
	for <linux-mm@kvack.org>; Mon, 21 Nov 2011 12:16:52 -0500 (EST)
Message-ID: <4ECA8781.7090302@redhat.com>
Date: Mon, 21 Nov 2011 12:16:49 -0500
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] mm: compaction: Allow compaction to isolate dirty
 pages
References: <1321635524-8586-1-git-send-email-mgorman@suse.de> <1321635524-8586-2-git-send-email-mgorman@suse.de>
In-Reply-To: <1321635524-8586-2-git-send-email-mgorman@suse.de>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Linux-MM <linux-mm@kvack.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, LKML <linux-kernel@vger.kernel.org>

On 11/18/2011 11:58 AM, Mel Gorman wrote:
> Commit [39deaf85: mm: compaction: make isolate_lru_page() filter-aware]
> noted that compaction does not migrate dirty or writeback pages and
> that is was meaningless to pick the page and re-add it to the LRU list.
>
> What was missed during review is that asynchronous migration moves
> dirty pages if their ->migratepage callback is migrate_page() because
> these can be moved without blocking. This potentially impacted
> hugepage allocation success rates by a factor depending on how many
> dirty pages are in the system.
>
> This patch partially reverts 39deaf85 to allow migration to isolate
> dirty pages again. This increases how much compaction disrupts the
> LRU but that is addressed later in the series.
>
> Signed-off-by: Mel Gorman<mgorman@suse.de>

Reviewed-by: Rik van Riel <riel@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
