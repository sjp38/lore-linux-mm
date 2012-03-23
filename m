Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx172.postini.com [74.125.245.172])
	by kanga.kvack.org (Postfix) with SMTP id 1BF456B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 00:48:20 -0400 (EDT)
Received: by iajr24 with SMTP id r24so5360153iaj.14
        for <linux-mm@kvack.org>; Thu, 22 Mar 2012 21:48:19 -0700 (PDT)
Date: Fri, 23 Mar 2012 13:48:11 +0900
From: Minchan Kim <minchan@kernel.org>
Subject: Re: [PATCH v6 3/7] mm: push lru index into shrink_[in]active_list()
Message-ID: <20120323044811.GA2717@barrios-desktop>
References: <20120322214944.27814.42039.stgit@zurg>
 <20120322215627.27814.4499.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120322215627.27814.4499.stgit@zurg>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konstantin Khlebnikov <khlebnikov@openvz.org>
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, Hugh Dickins <hughd@google.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Fri, Mar 23, 2012 at 01:56:27AM +0400, Konstantin Khlebnikov wrote:
> Let's toss lru index through call stack to isolate_lru_pages(),
> this is better than its reconstructing from individual bits.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Acked-by: Hugh Dickins <hughd@google.com>
> ---
>  mm/vmscan.c |   41 +++++++++++++++++------------------------
>  1 files changed, 17 insertions(+), 24 deletions(-)
> 
> diff --git a/mm/vmscan.c b/mm/vmscan.c
> index f4dca0c..fb6d54e 100644
> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1127,15 +1127,14 @@ int __isolate_lru_page(struct page *page, isolate_mode_t mode, int file)
>   * @nr_scanned:	The number of pages that were scanned.
>   * @sc:		The scan_control struct for this reclaim session
>   * @mode:	One of the LRU isolation modes
> - * @active:	True [1] if isolating active pages
> - * @file:	True [1] if isolating file [!anon] pages
> + * @lru		LRU list id for isolating

Missing colon.

Otherwise, nice cleanup!

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
