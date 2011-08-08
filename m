Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 5063E6B0169
	for <linux-mm@kvack.org>; Sun,  7 Aug 2011 21:04:27 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id E96243EE0C0
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:04:23 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C1CB645DE86
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:04:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id A68B645DE7F
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:04:23 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 96AD31DB8043
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:04:23 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 4D4C31DB803E
	for <linux-mm@kvack.org>; Mon,  8 Aug 2011 10:04:23 +0900 (JST)
Date: Mon, 8 Aug 2011 09:56:53 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH 1/4] page cgroup: using vzalloc instead of vmalloc
Message-Id: <20110808095653.96f92e85.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
References: <1312427390-20005-1-git-send-email-lliubbo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, cesarb@cesarb.net, emunson@mgebm.net, penberg@kernel.org, namhyung@gmail.com, hannes@cmpxchg.org, mhocko@suse.cz, lucas.demarchi@profusion.mobi, aarcange@redhat.com, tj@kernel.org, vapier@gentoo.org, jkosina@suse.cz, rientjes@google.com, dan.magenheimer@oracle.com

On Thu, 4 Aug 2011 11:09:47 +0800
Bob Liu <lliubbo@gmail.com> wrote:

> Signed-off-by: Bob Liu <lliubbo@gmail.com>

Reviewed-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>  mm/page_cgroup.c |    3 +--
>  1 files changed, 1 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 39d216d..6bdc67d 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -513,11 +513,10 @@ int swap_cgroup_swapon(int type, unsigned long max_pages)
>  	length = DIV_ROUND_UP(max_pages, SC_PER_PAGE);
>  	array_size = length * sizeof(void *);
>  
> -	array = vmalloc(array_size);
> +	array = vzalloc(array_size);
>  	if (!array)
>  		goto nomem;
>  
> -	memset(array, 0, array_size);
>  	ctrl = &swap_cgroup_ctrl[type];
>  	mutex_lock(&swap_cgroup_mutex);
>  	ctrl->length = length;
> -- 
> 1.6.3.3
> 
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
