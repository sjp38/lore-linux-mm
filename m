Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 3F56C6B0092
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 10:00:14 -0500 (EST)
Received: by pvc30 with SMTP id 30so574859pvc.14
        for <linux-mm@kvack.org>; Thu, 09 Dec 2010 07:00:11 -0800 (PST)
Date: Thu, 9 Dec 2010 23:59:59 +0900
From: Minchan Kim <minchan.kim@gmail.com>
Subject: Re: [PATCH] compaction: Remove mem_cgroup_del_lru
Message-ID: <20101209145959.GA1740@barrios-desktop>
References: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1291734086-1405-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Balbir Singh <balbir@linux.vnet.ibm.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Johannes Weiner <hannes@cmpxchg.org>
List-ID: <linux-mm.kvack.org>

On Wed, Dec 08, 2010 at 12:01:26AM +0900, Minchan Kim wrote:
> del_page_from_lru_list alreay called mem_cgroup_del_lru.
> So we need to call it again. It makes wrong stat of memcg and
> even happen VM_BUG_ON hit.
> 
> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Mel Gorman <mel@csn.ul.ie>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/compaction.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/compaction.c b/mm/compaction.c
> index 50b0a90..b0fbfdf 100644
> --- a/mm/compaction.c
> +++ b/mm/compaction.c
> @@ -302,7 +302,6 @@ static unsigned long isolate_migratepages(struct zone *zone,
>  		/* Successfully isolated */
>  		del_page_from_lru_list(zone, page, page_lru(page));
>  		list_add(&page->lru, migratelist);
> -		mem_cgroup_del_lru(page);
>  		cc->nr_migratepages++;
>  		nr_isolated++;
>  
> -- 
> 1.7.0.4
> 

Hi Andrew, 
Please drop above(mm-compactionc-avoid-double-mem_cgroup_del_lru.patch)
This is a new version with modified description and added Acked-by.
