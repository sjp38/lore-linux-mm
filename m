Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id C68876B00DA
	for <linux-mm@kvack.org>; Mon, 12 Dec 2011 06:23:25 -0500 (EST)
Date: Mon, 12 Dec 2011 12:23:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix a typo in documentation
Message-ID: <20111212112322.GB14720@tiehlicka.suse.cz>
References: <1323476120-8964-1-git-send-email-yinghan@google.com>
 <20111212105134.GA18789@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111212105134.GA18789@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ying Han <yinghan@google.com>, Balbir Singh <bsingharora@gmail.com>, Rik van Riel <riel@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mel@csn.ul.ie>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Pavel Emelyanov <xemul@openvz.org>, linux-mm@kvack.org

On Mon 12-12-11 11:51:34, Johannes Weiner wrote:
[...]
> From: Johannes Weiner <hannes@cmpxchg.org>
> Subject: [patch] Documentation: memcg: future proof hierarchical statistics
>  documentation
> 
> The hierarchical versions of per-memcg counters in memory.stat are all
> calculated the same way and are all named total_<counter>.
> 
> Documenting the pattern is easier for maintenance than listing each
> counter twice.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Yes, makes sense for the future maintenance.

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  Documentation/cgroups/memory.txt |   15 ++++-----------
>  1 files changed, 4 insertions(+), 11 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index 06eb6d9..a858675 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -404,17 +404,10 @@ hierarchical_memory_limit - # of bytes of memory limit with regard to hierarchy
>  hierarchical_memsw_limit - # of bytes of memory+swap limit with regard to
>  			hierarchy under which memory cgroup is.
>  
> -total_cache		- sum of all children's "cache"
> -total_rss		- sum of all children's "rss"
> -total_mapped_file	- sum of all children's "mapped_file"
> -total_pgpgin		- sum of all children's "pgpgin"
> -total_pgpgout		- sum of all children's "pgpgout"
> -total_swap		- sum of all children's "swap"
> -total_inactive_anon	- sum of all children's "inactive_anon"
> -total_active_anon	- sum of all children's "active_anon"
> -total_inactive_file	- sum of all children's "inactive_file"
> -total_active_file	- sum of all children's "active_file"
> -total_unevictable	- sum of all children's "unevictable"
> +total_<counter>		- # hierarchical version of <counter>, which in
> +			addition to the cgroup's own value includes the
> +			sum of all hierarchical children's values of
> +			<counter>, i.e. total_cache
>  
>  # The following additional stats are dependent on CONFIG_DEBUG_VM.
>  
> -- 
> 1.7.7.3
> 

-- 
Michal Hocko
SUSE Labs
SUSE LINUX s.r.o.
Lihovarska 1060/12
190 00 Praha 9    
Czech Republic

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
