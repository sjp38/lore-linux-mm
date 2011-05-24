Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 141C16B0011
	for <linux-mm@kvack.org>; Tue, 24 May 2011 03:07:32 -0400 (EDT)
Received: from m1.gw.fujitsu.co.jp (unknown [10.0.50.71])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 853D63EE0BC
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:29 +0900 (JST)
Received: from smail (m1 [127.0.0.1])
	by outgoing.m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 6E78E45DF6D
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (s1.gw.fujitsu.co.jp [10.0.50.91])
	by m1.gw.fujitsu.co.jp (Postfix) with ESMTP id 56BA645DF64
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:29 +0900 (JST)
Received: from s1.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 46BE1EF8001
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:29 +0900 (JST)
Received: from ml13.s.css.fujitsu.com (ml13.s.css.fujitsu.com [10.240.81.133])
	by s1.gw.fujitsu.co.jp (Postfix) with ESMTP id 0EEADE08002
	for <linux-mm@kvack.org>; Tue, 24 May 2011 16:07:29 +0900 (JST)
Message-ID: <4DDB5925.5000706@jp.fujitsu.com>
Date: Tue, 24 May 2011 16:07:17 +0900
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH V2] memcg: add documentation for memory.numastat API.
References: <1306220513-7763-1-git-send-email-yinghan@google.com>
In-Reply-To: <1306220513-7763-1-git-send-email-yinghan@google.com>
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: yinghan@google.com
Cc: minchan.kim@gmail.com, nishimura@mxp.nes.nec.co.jp, balbir@linux.vnet.ibm.com, tj@kernel.org, xemul@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, akpm@linux-foundation.org, lizf@cn.fujitsu.com, mel@csn.ul.ie, cl@linux.com, hannes@cmpxchg.org, riel@redhat.com, hughd@google.com, mhocko@suse.cz, dave@linux.vnet.ibm.com, zhu.yanhai@gmail.com, linux-mm@kvack.org

(2011/05/24 16:01), Ying Han wrote:
> change v2..v1:
> 1. add sample output.
> 
> Signed-off-by: Ying Han <yinghan@google.com>
> ---
>  Documentation/cgroups/memory.txt |   18 ++++++++++++++++++
>  1 files changed, 18 insertions(+), 0 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 2d7e527..0b1a1ce 100644
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
> @@ -477,6 +478,23 @@ value for efficient access. (Of course, when necessary, it's synchronized.)
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
> +The format ouput of the memory.numa_stat:
> +
> +total=<total pages> N0=<node 0 pages> N1=<node 1 pages> ...
> +file=<total file pages> N0=<node 0 pages> N1=<node 1 pages> ...
> +anon=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> +unevictable=<total anon pages> N0=<node 0 pages> N1=<node 1 pages> ...
> +
> +And we have total = file + anon + unevictable.
> +

Looks good to me.
	Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
