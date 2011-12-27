Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx188.postini.com [74.125.245.188])
	by kanga.kvack.org (Postfix) with SMTP id 724CB6B004F
	for <linux-mm@kvack.org>; Tue, 27 Dec 2011 09:11:31 -0500 (EST)
Date: Tue, 27 Dec 2011 15:11:28 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 4/6] memcg: mark stat field of mem_cgroup struct as
 __percpu
Message-ID: <20111227141128.GN5344@tiehlicka.suse.cz>
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name>
 <1324695619-5537-4-git-send-email-kirill@shutemov.name>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1324695619-5537-4-git-send-email-kirill@shutemov.name>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill@shutemov.name>
Cc: linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>

On Sat 24-12-11 05:00:17, Kirill A. Shutemov wrote:
> From: "Kirill A. Shutemov" <kirill@shutemov.name>
> 
> It fixes a lot of sparse warnings.
> 
> Signed-off-by: Kirill A. Shutemov <kirill@shutemov.name>

Looks good.
Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  mm/memcontrol.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 627c19e..b27ce0f 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -291,7 +291,7 @@ struct mem_cgroup {
>  	/*
>  	 * percpu counter.
>  	 */
> -	struct mem_cgroup_stat_cpu *stat;
> +	struct mem_cgroup_stat_cpu __percpu *stat;
>  	/*
>  	 * used when a cpu is offlined or other synchronizations
>  	 * See mem_cgroup_read_stat().
> -- 
> 1.7.7.3
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

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
