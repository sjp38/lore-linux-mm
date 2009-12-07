Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1D036B0044
	for <linux-mm@kvack.org>; Sun,  6 Dec 2009 23:17:53 -0500 (EST)
Date: Mon, 7 Dec 2009 13:13:22 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH] memcg: code clean,rm unused variable in
 mem_cgroup_resize_limit
Message-Id: <20091207131322.fdb195b5.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <cf18f8340912061837j16c9aa25vc6af8a4a1fce989c@mail.gmail.com>
References: <cf18f8340912061837j16c9aa25vc6af8a4a1fce989c@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, balbir@linux.vnet.ibm.com, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
List-ID: <linux-mm.kvack.org>

(Added Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>)

On Mon, 7 Dec 2009 10:37:24 +0800, Bob Liu <lliubbo@gmail.com> wrote:
> Variable progress isn't used in funtion mem_cgroup_resize_limit anymore.
> Remove it.
> 
Indeed.

One minor nitpick.

> Signed-off-by: Bob Liu <lliubbo@gmail.com>
> ---
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 984cf27..9d4776e 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2100,7 +2100,6 @@ static int mem_cgroup_resize_limit(struct
> mem_cgroup *memcg,
>  				unsigned long long val)
>  {
>  	int retry_count;
> -	int progress;
>  	u64 memswlimit;
>  	int ret = 0;
>  	int children = mem_cgroup_count_children(memcg);
> @@ -2144,7 +2143,7 @@ static int mem_cgroup_resize_limit(struct
> mem_cgroup *memcg,
>  		if (!ret)
>  			break;
> 
> -		progress = mem_cgroup_hierarchical_reclaim(memcg, NULL,
> +		mem_cgroup_hierarchical_reclaim(memcg, NULL,
>  						GFP_KERNEL,
>  						MEM_CGROUP_RECLAIM_SHRINK);
Could you merge "GFP_KERNEL," to the previous line ?
It can reduces 1 line as a result.


Thanks,
Daisuke Nishimura.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
