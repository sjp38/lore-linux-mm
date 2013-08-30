Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx200.postini.com [74.125.245.200])
	by kanga.kvack.org (Postfix) with SMTP id 346556B0033
	for <linux-mm@kvack.org>; Fri, 30 Aug 2013 00:03:54 -0400 (EDT)
Message-ID: <52201985.1090909@huawei.com>
Date: Fri, 30 Aug 2013 12:03:17 +0800
From: Jianguo Wu <wujianguo@huawei.com>
MIME-Version: 1.0
Subject: Re: [PATCH 5/5] mm/cgroup: use N_MEMORY instead of N_HIGH_MEMORY
References: <52201539.8050003@huawei.com>
In-Reply-To: <52201539.8050003@huawei.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizefan@huawei.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, tj@kernel.org, laijs@cn.fujitsu.com, cgroups@vger.kernel.org, containers@lists.linux-foundation.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 2013/8/30 11:44, Jianguo Wu wrote:

> Since commit 8219fc48a(mm: node_states: introduce N_MEMORY),
> we introduced N_MEMORY, now N_MEMORY stands for the nodes that has any memory,
> and N_HIGH_MEMORY stands for the nodes that has normal or high memory.
> 
> The code here need to handle with the nodes which have memory,
> we should use N_MEMORY instead.
> 
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>

Sorry, it's should be "Signed-off-by: Jianguo Wu <wujianguo@huawei.com>"

> ---
>  mm/page_cgroup.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/page_cgroup.c b/mm/page_cgroup.c
> index 6d757e3..f6f7603 100644
> --- a/mm/page_cgroup.c
> +++ b/mm/page_cgroup.c
> @@ -116,7 +116,7 @@ static void *__meminit alloc_page_cgroup(size_t size, int nid)
>  		return addr;
>  	}
>  
> -	if (node_state(nid, N_HIGH_MEMORY))
> +	if (node_state(nid, N_MEMORY))
>  		addr = vzalloc_node(size, nid);
>  	else
>  		addr = vzalloc(size);



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
