Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 06D926B0005
	for <linux-mm@kvack.org>; Mon,  8 Apr 2013 23:58:30 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 7318D3EE0BD
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:58:29 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 5B4A32E68C9
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:58:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2BF721EF085
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:58:29 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id 1AFD01DB8040
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:58:29 +0900 (JST)
Received: from m1000.s.css.fujitsu.com (m1000.s.css.fujitsu.com [10.240.81.136])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id BCD631DB8037
	for <linux-mm@kvack.org>; Tue,  9 Apr 2013 12:58:28 +0900 (JST)
Message-ID: <516391D1.2060508@jp.fujitsu.com>
Date: Tue, 09 Apr 2013 12:58:09 +0900
From: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 3/8] memcg: convert to use cgroup_is_ancestor()
References: <51627DA9.7020507@huawei.com> <51627DFA.9050007@huawei.com>
In-Reply-To: <51627DFA.9050007@huawei.com>
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Li Zefan <lizefan@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Glauber Costa <glommer@parallels.com>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, LKML <linux-kernel@vger.kernel.org>, Cgroups <cgroups@vger.kernel.org>, linux-mm@kvack.org

(2013/04/08 17:21), Li Zefan wrote:
> This is a preparation to kill css_id.
> 
> Signed-off-by: Li Zefan <lizefan@huawei.com>
> ---
>   mm/memcontrol.c | 2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 5aa6e91..14f1375 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1383,7 +1383,7 @@ bool __mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
>   		return true;
>   	if (!root_memcg->use_hierarchy || !memcg)
>   		return false;
> -	return css_is_ancestor(&memcg->css, &root_memcg->css);
> +	return cgroup_is_ancestor(memcg->css.cgroup, root_memcg->css.cgroup);
>   }
>   
>   static bool mem_cgroup_same_or_subtree(const struct mem_cgroup *root_memcg,
> 

Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
