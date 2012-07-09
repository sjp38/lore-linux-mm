Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx165.postini.com [74.125.245.165])
	by kanga.kvack.org (Postfix) with SMTP id 6FA8E6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 00:40:10 -0400 (EDT)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 110693EE0BD
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:40:09 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id E130445DE56
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:40:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id C678445DE4D
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:40:08 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id B58691DB803A
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:40:08 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 27A561DB8042
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 13:40:08 +0900 (JST)
Message-ID: <4FFA6023.4060806@jp.fujitsu.com>
Date: Mon, 09 Jul 2012 13:37:55 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] mm/memcg: replace inexistence move_lock_page_cgroup()
 by move_lock_mem_cgroup() in comment
References: <a> <1341469733-12104-1-git-send-email-liwp.linux@gmail.com>
In-Reply-To: <1341469733-12104-1-git-send-email-liwp.linux@gmail.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

(2012/07/05 15:28), Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>


> ---
>   mm/memcontrol.c |    4 ++--
>   1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 3d318f6..63e36e7 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1899,7 +1899,7 @@ again:
>   		return;
>   	/*
>   	 * If this memory cgroup is not under account moving, we don't
> -	 * need to take move_lock_page_cgroup(). Because we already hold
> +	 * need to take move_lock_mem_cgroup(). Because we already hold
>   	 * rcu_read_lock(), any calls to move_account will be delayed until
>   	 * rcu_read_unlock() if mem_cgroup_stolen() == true.
>   	 */
> @@ -1921,7 +1921,7 @@ void __mem_cgroup_end_update_page_stat(struct page *page, unsigned long *flags)
>   	/*
>   	 * It's guaranteed that pc->mem_cgroup never changes while
>   	 * lock is held because a routine modifies pc->mem_cgroup
> -	 * should take move_lock_page_cgroup().
> +	 * should take move_lock_mem_cgroup().
>   	 */
>   	move_unlock_mem_cgroup(pc->mem_cgroup, flags);
>   }
> 



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
