Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 173D26B003D
	for <linux-mm@kvack.org>; Tue, 10 Feb 2009 17:07:28 -0500 (EST)
Date: Tue, 10 Feb 2009 14:06:37 -0800
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] vmscan: initialize sc->nr_reclaimed properly take2
Message-Id: <20090210140637.902e4dcc.akpm@linux-foundation.org>
In-Reply-To: <20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
References: <20090210213502.7007.KOSAKI.MOTOHIRO@jp.fujitsu.com>
	<28c262360902100440v765d3f7bnd56cc4b5510349c0@mail.gmail.com>
	<20090210215718.700D.KOSAKI.MOTOHIRO@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Cc: minchan.kim@gmail.com, hannes@cmpxchg.org, riel@redhat.com, wli@movementarian.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 10 Feb 2009 21:58:04 +0900 (JST)
KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com> wrote:

> --- a/mm/vmscan.c
> +++ b/mm/vmscan.c
> @@ -1665,6 +1665,7 @@ unsigned long try_to_free_pages(struct z
>  								gfp_t gfp_mask)
>  {
>  	struct scan_control sc = {
> +		.nr_reclaimed = 0,
>  		.gfp_mask = gfp_mask,
>  		.may_writepage = !laptop_mode,
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
> @@ -1686,6 +1687,7 @@ unsigned long try_to_free_mem_cgroup_pag
>  					   unsigned int swappiness)
>  {
>  	struct scan_control sc = {
> +		.nr_reclaimed = 0,
>  		.may_writepage = !laptop_mode,
>  		.may_swap = 1,
>  		.swap_cluster_max = SWAP_CLUSTER_MAX,
> @@ -2245,6 +2247,7 @@ static int __zone_reclaim(struct zone *z
>  	struct reclaim_state reclaim_state;
>  	int priority;
>  	struct scan_control sc = {
> +		.nr_reclaimed = 0,
>  		.may_writepage = !!(zone_reclaim_mode & RECLAIM_WRITE),
>  		.may_swap = !!(zone_reclaim_mode & RECLAIM_SWAP),
>  		.swap_cluster_max = max_t(unsigned long, nr_pages,

Confused.  The compiler already initialises any unmentioned fields to zero,
so this patch has no effect.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
