Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id 9D5526B0074
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 04:30:00 -0400 (EDT)
Date: Fri, 6 Jul 2012 10:29:47 +0200
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH v2] mm/memcg: mem_cgroup_resize_xxx_limit can guarantee
 memcg->res.limit <= memcg->memsw.limit
Message-ID: <20120706082947.GB1230@cmpxchg.org>
References: <1341545055-5830-1-git-send-email-liwp.linux@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341545055-5830-1-git-send-email-liwp.linux@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwp.linux@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 06, 2012 at 11:24:15AM +0800, Wanpeng Li wrote:
> From: Wanpeng Li <liwp@linux.vnet.ibm.com>
> 
> Changlog:
> 
> V2:
> * correct title

Would it be possible to collect all these comment fixes you send out
every other day into a single patch?

> Signed-off-by: Wanpeng Li <liwp.linux@gmail.com>
> ---
>  mm/memcontrol.c |    4 ++--
>  1 files changed, 2 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 4b64fe0..a501660 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -3418,7 +3418,7 @@ static int mem_cgroup_resize_limit(struct mem_cgroup *memcg,
>  		/*
>  		 * Rather than hide all in some function, I do this in
>  		 * open coded manner. You see what this really does.
> -		 * We have to guarantee memcg->res.limit < memcg->memsw.limit.
> +		 * We have to guarantee memcg->res.limit <= memcg->memsw.limit.
>  		 */

It would probably make sense to also remove the first two sentences,
they add nothing of value.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
