Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx173.postini.com [74.125.245.173])
	by kanga.kvack.org (Postfix) with SMTP id 26D7B6B00F3
	for <linux-mm@kvack.org>; Fri, 27 Apr 2012 14:20:24 -0400 (EDT)
Received: by dadq36 with SMTP id q36so1411366dad.8
        for <linux-mm@kvack.org>; Fri, 27 Apr 2012 11:20:23 -0700 (PDT)
Date: Fri, 27 Apr 2012 11:20:18 -0700
From: Tejun Heo <tj@kernel.org>
Subject: Re: [RFC][PATCH 4/7 v2] memcg: use res_counter_uncharge_until in
 move_parent
Message-ID: <20120427182018.GI26595@google.com>
References: <4F9A327A.6050409@jp.fujitsu.com>
 <4F9A34B2.8080103@jp.fujitsu.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F9A34B2.8080103@jp.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: Linux Kernel <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "cgroups@vger.kernel.org" <cgroups@vger.kernel.org>, Michal Hocko <mhocko@suse.cz>, Johannes Weiner <hannes@cmpxchg.org>, Frederic Weisbecker <fweisbec@gmail.com>, Glauber Costa <glommer@parallels.com>, Han Ying <yinghan@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, kamezawa.hiroyuki@gmail.com

On Fri, Apr 27, 2012 at 02:54:58PM +0900, KAMEZAWA Hiroyuki wrote:
> By using res_counter_uncharge_until(), we can avoid 
> unnecessary charging.
> 
> Signed-off-by: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> ---
>  mm/memcontrol.c |   63 ++++++++++++++++++++++++++++++++++++------------------
>  1 files changed, 42 insertions(+), 21 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 613bb15..ed53d64 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -2420,6 +2420,24 @@ static void __mem_cgroup_cancel_charge(struct mem_cgroup *memcg,
>  }
>  
>  /*
> + * Cancel chages in this cgroup....doesn't propagates to parent cgroup.

             ^typo                                     ^ unnecessary s

-- 
tejun

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
