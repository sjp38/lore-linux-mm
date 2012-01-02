Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id 3D3D16B004D
	for <linux-mm@kvack.org>; Mon,  2 Jan 2012 06:53:27 -0500 (EST)
Date: Mon, 2 Jan 2012 12:53:22 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
Message-ID: <20120102115322.GE7910@tiehlicka.suse.cz>
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils>
 <alpine.LSU.2.00.1112312326540.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.00.1112312326540.18500@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Balbir Singh <bsingharora@gmail.com>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

On Sat 31-12-11 23:27:59, Hugh Dickins wrote:
> Correct an #endif comment in memcontrol.h from MEM_CONT to MEM_RES_CTLR.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks

> ---
>  include/linux/memcontrol.h |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm.orig/include/linux/memcontrol.h	2011-12-30 21:21:34.923338593 -0800
> +++ mmotm/include/linux/memcontrol.h	2011-12-30 21:21:51.939338993 -0800
> @@ -396,7 +396,7 @@ static inline void mem_cgroup_replace_pa
>  static inline void mem_cgroup_reset_owner(struct page *page)
>  {
>  }
> -#endif /* CONFIG_CGROUP_MEM_CONT */
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */
>  
>  #if !defined(CONFIG_CGROUP_MEM_RES_CTLR) || !defined(CONFIG_DEBUG_VM)
>  static inline bool

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
