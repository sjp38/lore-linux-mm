Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx183.postini.com [74.125.245.183])
	by kanga.kvack.org (Postfix) with SMTP id 244D56B0072
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 00:46:55 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 7CFE93EE0AE
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:46:53 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 63F0445DEB4
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:46:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 4C63545DE7E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:46:53 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 3F5F81DB8045
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:46:53 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id E9CBA1DB803B
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:46:52 +0900 (JST)
Message-ID: <4FFA61BC.4020102@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 13:44:44 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: mem_cgroup_relize_xxx_limit can guarantee memcg->res.limit
 <= memcg->memsw.limit
References: <1341544860-5634-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1341544860-5634-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/07/06 12:21), Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

Could you merge all 'commentary fixes' into a patch ?


> ---
>   mm/memcontrol.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4b64fe0..a501660 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3418,7 +3418,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>   		/*
>   		 * Rather than hide all in some function, I do this in
>   		 * open coded manner. You see what this really does.
> -		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
> +		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
>   		 */
>   		mutex_lock(&set_limit_mutex);
>   		memswlimit = res_counter_read_u64(&memcg->memsw, RES_LIMIT);
> @@ -3479,7 +3479,7 @@ static int mem_cgroup_resize_memsw_limit(struct mem_cgroup *memcg,
>   		/*
>   		 * Rather than hide all in some function, I do this in
>   		 * open coded manner. You see what this really does.
> -		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
> +		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
>   		 */
>   		mutex_lock(&set_limit_mutex);
>   		memlimit = res_counter_read_u64(&memcg->res, RES_LIMIT);
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
