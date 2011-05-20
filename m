Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id CF07D6B0012
	for <linux-mm@kvack.org>; Thu, 19 May 2011 22:19:59 -0400 (EDT)
Date: Fri, 20 May 2011 11:11:05 +0900
From: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>
Subject: Re: [PATCH V3 2/3] memcg: fix a routine for counting pages in node
Message-Id: <20110520111105.d6f5ca1b.nishimura@mxp.nes.nec.co.jp>
In-Reply-To: <1305826360-2167-2-git-send-email-yinghan@google.com>
References: <1305826360-2167-1-git-send-email-yinghan@google.com>
	<1305826360-2167-2-git-send-email-yinghan@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Minchan Kim <minchan.kim@gmail.com>, Balbir Singh <balbir@linux.vnet.ibm.com>, Tejun Heo <tj@kernel.org>, Pavel Emelyanov <xemul@openvz.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Andrew Morton <akpm@linux-foundation.org>, Li Zefan <lizf@cn.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>, Christoph Lameter <cl@linux.com>, Johannes Weiner <hannes@cmpxchg.org>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Dave Hansen <dave@linux.vnet.ibm.com>, Zhu Yanhai <zhu.yanhai@gmail.com>, linux-mm@kvack.org, Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

Acked-by: Daisuke Nishimura <nishimura@mxp.nes.nec.co.jp>

This is a bugfix for memcg-reclaim-memory-from-nodes-in-round-robin-order.patch
in mmotm tree, so I think it would be better to note about it.

On Thu, 19 May 2011 10:32:39 -0700
Ying Han <yinghan@google.com> wrote:

> The value for counter base should be initialized. If not,
> this returns wrong value.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index da183dc..e14677c 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -679,7 +679,7 @@ static unsigned long
>  mem_cgroup_get_zonestat_node(struct mem_cgroup *mem, int nid, enum lru_list idx)
>  {
>  	struct mem_cgroup_per_zone *mz;
> -	u64 total;
> +	u64 total = 0;
>  	int zid;
>  
>  	for (zid = 0; zid < MAX_NR_ZONES; zid++) {
> -- 
> 1.7.3.1
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
