Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 2AEF36B0002
	for <linux-mm@kvack.org>; Fri, 25 Jan 2013 02:37:41 -0500 (EST)
Message-ID: <5102364F.3020700@parallels.com>
Date: Fri, 25 Jan 2013 11:37:51 +0400
From: Lord Glauber Costa of Sealand <glommer@parallels.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2] memcg: reduce the size of struct memcg 244-fold.
References: <1359009996-5350-1-git-send-email-glommer@parallels.com> <xr93r4lbrpdk.fsf@gthelen.mtv.corp.google.com> <20130124155105.85dae9d9.akpm@linux-foundation.org>
In-Reply-To: <20130124155105.85dae9d9.akpm@linux-foundation.org>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Greg Thelen <gthelen@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Hugh Dickins <hughd@google.com>, Ying Han <yinghan@google.com>, Mel Gorman <mgorman@suse.de>, Rik van Riel <riel@redhat.com>


>  #ifdef CONFIG_MEMCG_KMEM
> -static inline void memcg_kmem_set_active(struct mem_cgroup *memcg)
> +static void memcg_kmem_set_active(struct mem_cgroup *memcg)
>  {
>  	set_bit(KMEM_ACCOUNTED_ACTIVE, &memcg->kmem_account_flags);
>  }
> @@ -645,6 +645,7 @@ static void drain_all_stock_async(struct
>  static struct mem_cgroup_per_zone *
>  mem_cgroup_zoneinfo(struct mem_cgroup *memcg, int nid, int zid)
>  {
> +	VM_BUG_ON((unsigned)nid >= nr_node_ids);
>  	return &memcg->info.nodeinfo[nid]->zoneinfo[zid];
>  }
>  
> _
> 
> Glauber, could you please cc me on patches more often?  It's a bit of a
> pita having to go back to the mailing list to see if there has been
> more dicussion and I may end up missing late review comments and acks.
> 
Sure, absolutely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
