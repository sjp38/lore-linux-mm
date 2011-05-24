Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with ESMTP id 29AA76B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 02:32:47 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id B97383EE0BC
	for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:42 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id A37C245DF46
	for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 87BEE45DF47
	for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:42 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7B93B1DB803B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:42 +0900 (JST)
Received: from m107.s.css.fujitsu.com (m107.s.css.fujitsu.com [10.240.81.147])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 454871DB8038
	for <linux-mm@kvack.org>; Tue, 24 May 2011 15:32:42 +0900 (JST)
Message-ID: <4DDB50F9.3030809@jp.fujitsu.com>
Date: Tue, 24 May 2011 15:32:25 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH] memcg: add documentation for memory.numastat API.
References: <1306218374-5597-1-git-send-email-yinghan@google.com>
In-Reply-To: <1306218374-5597-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghan@google.com
Cc: minchan.kim@gmail.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, tj@kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, lizf@cn.fujitsu.com, mel@csn.ul.ie, cl@linux.com, hannes@cmpxchg.org, riel@redhat.com, hughd@google.com, mhocko@suse.cz, dave@linux.vnet.ibm.com, zhu.yanhai@gmail.com, linux-mm@kvack.org

(2011/05/24 15:26), Ying Han wrote:
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  Documentation/cgroups/memory.txt |   10 ++++++++++
>  1 files changed, 10 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 2d7e527..b81be08 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -71,6 +71,7 @@ Brief summary of control files.
>   memory.move_charge_at_immigrate # set/show controls of moving charges
>   memory.oom_control		 # set/show oom controls.
>   memory.async_control		 # set control for asynchronous memory reclaim
> + memory.numa_stat		 # show the number of memory usage per numa node
>  
>  1. History
>  
> @@ -477,6 +478,15 @@ value for efficient access. (Of course, when necessary, it's synchronized.)
>  If you want to know more exact memory usage, you should use RSS+CACHE(+SWAP)
>  value in memory.stat(see 5.2).
>  
> +5.6 numa_stat
> +
> +This is similar to numa_maps but per-memcg basis. This is useful to add visibility
> +of numa locality information in memcg since the pages are allowed to be allocated
> +at any physical node. One of the usecase is evaluating application performance by
> +combining this information with the cpu allocation to the application.
> +
> +We export "total", "file", "anon" and "unevictable" pages per-node for each memcg.
> +

This assume reader know numa_maps. The beter explanation is to write example output
and explain its meanings.

Thanks.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
