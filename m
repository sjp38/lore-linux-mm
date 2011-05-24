Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 7F8836B0022
	for <linux-mm@kvack.org>; Tue, 24 May 2011 04:45:16 -0400 (EDT)
Received: from m4.gw.fujitsu.co.jp (unknown [10.0.50.74])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id 3D5E23EE0BC
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:45:13 +0900 (JST)
Received: from smail (m4 [127.0.0.1])
	by outgoing.m4.gw.fujitsu.co.jp (Postfix) with ESMTP id 2192C45DECA
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:45:13 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (s4.gw.fujitsu.co.jp [10.0.50.94])
	by m4.gw.fujitsu.co.jp (Postfix) with ESMTP id F2A9F45DEC3
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:45:12 +0900 (JST)
Received: from s4.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id E50841DB8040
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:45:12 +0900 (JST)
Received: from m106.s.css.fujitsu.com (m106.s.css.fujitsu.com [10.240.81.146])
	by s4.gw.fujitsu.co.jp (Postfix) with ESMTP id AF5DD1DB803B
	for <linux-mm@kvack.org>; Tue, 24 May 2011 17:45:12 +0900 (JST)
Date: Tue, 24 May 2011 17:37:17 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [PATCH V2] memcg: add documentation for memory.numastat API.
Message-Id: <20110524173717.8f2fb393.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <1306220513-7763-1-git-send-email-yinghan@google.com>
References: <1306220513-7763-1-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org

On Tue, 24 May 2011 00:01:53 -0700
Ying Han <yinghan@google.com> wrote:

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
>  6. Hierarchy support
>  

Thank you.
Acked-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
