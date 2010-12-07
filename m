Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 60B706B0087
	for <linux-mm@kvack.org>; Wed,  8 Dec 2010 00:07:35 -0500 (EST)
Received: from d23relay04.au.ibm.com (d23relay04.au.ibm.com [202.81.31.246])
	by e23smtp03.au.ibm.com (8.14.4/8.13.1) with ESMTP id oB853HnS031823
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 16:03:17 +1100
Received: from d23av03.au.ibm.com (d23av03.au.ibm.com [9.190.234.97])
	by d23relay04.au.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id oB857Vv92388144
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 16:07:31 +1100
Received: from d23av03.au.ibm.com (loopback [127.0.0.1])
	by d23av03.au.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id oB857Uj4026117
	for <linux-mm@kvack.org>; Wed, 8 Dec 2010 16:07:31 +1100
Date: Tue, 7 Dec 2010 20:46:42 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Subject: Re: [PATCH] memcg: Remove unnecessary return
Message-ID: <20101207151642.GK3158@balbir.in.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
References: <1291734580-19515-1-git-send-email-minchan.kim@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1291734580-19515-1-git-send-email-minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
To: Minchan Kim <minchan.kim@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

* MinChan Kim <minchan.kim@gmail.com> [2010-12-08 00:09:40]:

> Cc: Balbir Singh <balbir@linux.vnet.ibm.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Signed-off-by: Minchan Kim <minchan.kim@gmail.com>
> ---
>  mm/memcontrol.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index f9435be..55f57e3 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -821,7 +821,6 @@ void mem_cgroup_del_lru_list(struct page *page, enum lru_list lru)
>  		return;
>  	VM_BUG_ON(list_empty(&pc->lru));
>  	list_del_init(&pc->lru);
> -	return;
>  }
> 

Reviewed-by: Balbir Singh <balbir@linux.vnet.ibm.com>
 
-- 
	Three Cheers,
	Balbir

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
