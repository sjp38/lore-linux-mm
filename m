Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id C160F6B004F
	for <linux-mm@kvack.org>; Sat, 17 Dec 2011 20:53:27 -0500 (EST)
Received: by ghrr18 with SMTP id r18so3350707ghr.14
        for <linux-mm@kvack.org>; Sat, 17 Dec 2011 17:53:26 -0800 (PST)
Date: Sun, 18 Dec 2011 10:53:14 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH 06/11] mm: compaction: make isolate_lru_page()
 filter-aware again
Message-ID: <20111218015314.GA13069@barrios-laptop.redhat.com>
References: <1323877293-15401-1-git-send-email-mgorman@suse.de>
 <1323877293-15401-7-git-send-email-mgorman@suse.de>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1323877293-15401-7-git-send-email-mgorman@suse.de>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mgorman@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, Dave Jones <davej@redhat.com>, Jan Kara <jack@suse.cz>, Andy Isaacson <adi@hexapodia.org>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Nai Xia <nai.xia@gmail.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Wed, Dec 14, 2011 at 03:41:28PM +0000, Mel Gorman wrote:
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
> Signed-off-by: Mel Gorman <mgorman@suse.de>
Reviewed-by: Minchan Kim <minchan@kernel.org>

-- 
Kind regards,
Minchan Kim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
