Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id 037576B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 09:03:08 -0500 (EST)
Date: Mon, 28 Nov 2011 15:03:00 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix the document of pgpgin/pgpgout
Message-ID: <20111128140300.GB20174@tiehlicka.suse.cz>
References: <1321922925-14930-1-git-send-email-yinghan@google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1321922925-14930-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ying Han <yinghan@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Wanlong Gao <gaowanlong@cn.fujitsu.com>, cgroups@vger.kernel.org, linux-mm@kvack.org

On Mon 21-11-11 16:48:45, Ying Han wrote:
> The two memcg stats pgpgin/pgpgout have different meaning than the ones in
> vmstat, which indicates that we picked a bad naming for them. It might be late
> to change the stat name, but better documentation is always helpful.
> 
> Signed-off-by: Ying Han <yinghan@google.com>

If not too late
Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  Documentation/cgroups/memory.txt |    7 +++++--
>  1 files changed, 5 insertions(+), 2 deletions(-)
> 
> diff --git a/Documentation/cgroups/memory.txt b/Documentation/cgroups/memory.txt
> index cc0ebc5..eb6a911 100644
> --- a/Documentation/cgroups/memory.txt
> +++ b/Documentation/cgroups/memory.txt
> @@ -386,8 +386,11 @@ memory.stat file includes following statistics
>  cache		- # of bytes of page cache memory.
>  rss		- # of bytes of anonymous and swap cache memory.
>  mapped_file	- # of bytes of mapped file (includes tmpfs/shmem)
> -pgpgin		- # of pages paged in (equivalent to # of charging events).
> -pgpgout		- # of pages paged out (equivalent to # of uncharging events).
> +pgpgin		- # of charging events to the memory cgroup. The charging
> +		event happens each time a page is accounted as either mapped
> +		anon page(RSS) or cache page(Page Cache) to the cgroup.
> +pgpgout		- # of uncharging events to the memory cgroup. The uncharging
> +		event happens each time a page is unaccounted from the cgroup.
>  swap		- # of bytes of swap usage
>  inactive_anon	- # of bytes of anonymous memory and swap cache memory on
>  		LRU list.
> -- 
> 1.7.3.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe cgroups" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

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
