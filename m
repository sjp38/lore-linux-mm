Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 81AC16B0005
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 05:43:46 -0500 (EST)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail5.fujitsu.co.jp (Postfix) with ESMTP id 2E7F73EE0BD
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:43:45 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 0E46E45DEC5
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:43:45 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id E702F45DEBA
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:43:44 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id D32B81DB8045
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:43:44 +0900 (JST)
Received: from ml14.s.css.fujitsu.com (ml14.s.css.fujitsu.com [10.240.81.134])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 81ABE1DB803B
	for <linux-mm@kvack.org>; Wed, 13 Feb 2013 19:43:44 +0900 (JST)
Message-ID: <511B6E52.1090800@jp.fujitsu.com>
Date: Wed, 13 Feb 2013 19:43:30 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 2/2] memcg: replace cgroup_lock with memcg specific memcg_lock
 fix
References: <1360569889-843-1-git-send-email-glommer@parallels.com> <1360569889-843-3-git-send-email-glommer@parallels.com>
In-Reply-To: <1360569889-843-3-git-send-email-glommer@parallels.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>

(2013/02/11 17:04), Glauber Costa wrote:
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

I'm sorry I missed this...
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

> ---
>   mm/memcontrol.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 28252c9..03ebf68 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -5884,7 +5884,7 @@ static int mem_cgroup_oom_control_write(struct cgroup *cgrp,
>   	mutex_lock(&memcg_create_mutex);
>   	/* oom-kill-disable is a flag for subhierarchy. */
>   	if ((parent->use_hierarchy) || memcg_has_children(memcg)) {
> -		cgroup_unlock();
> +		mutex_unlock(&memcg_create_mutex);
>   		return -EINVAL;
>   	}
>   	memcg->oom_kill_disable = val;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
