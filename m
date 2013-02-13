Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx135.postini.com [74.125.245.135])
	by kanga.kvack.org (Postfix) with SMTP id 2A05C6B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 05:42:40 -0500 (EST)
Received: from m2.gw.fujitsu.co.jp (unknown [10.0.50.72])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C3A3C3EE0BB
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:42:38 +0900 (JST)
Received: from smail (m2 [127.0.0.1])
	by outgoing.m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 9810B45DE55
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:42:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (s2.gw.fujitsu.co.jp [10.0.50.92])
	by m2.gw.fujitsu.co.jp (Postfix) with ESMTP id 5FE7245DE50
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:42:38 +0900 (JST)
Received: from s2.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id 48DDC1DB8041
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:42:38 +0900 (JST)
Received: from m1001.s.css.fujitsu.com (m1001.s.css.fujitsu.com [10.240.81.139])
	by s2.gw.fujitsu.co.jp (Postfix) with ESMTP id F33CA1DB803E
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:42:37 +0900 (JST)
Message-ID: <511B6E0D.3030703@jp.fujitsu.com>
Date: Wed, 13 Feb 2013 19:42:21 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] memcg: fast hierarchy-aware child test fix
References: <1360569889-843-1-git-send-email-glommer@parallels.com> <1360569889-843-2-git-send-email-glommer@parallels.com>
In-Reply-To: <1360569889-843-2-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/02/11 17:04), Glauber Costa wrote:
> ---
>   mm/memcontrol.c | 3 +--
>   1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 25ac5f4..28252c9 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5883,8 +5883,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>   
>   	mutex_lock(&memcg_create_mutex);
>   	/* oom-kill-disable is a flag for subhierarchy. */
> -	if ((parent->use_hierarchy) ||
> -	    (memcg->use_hierarchy && !list_empty(&cgrp->children))) {
> +	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
>   		cgroup_unlock();
>   		return -EINVAL;
>   	}
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
