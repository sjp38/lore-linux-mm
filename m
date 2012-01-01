Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx150.postini.com [74.125.245.150])
	by kanga.kvack.org (Postfix) with SMTP id 29A1E6B0088
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:34:03 -0500 (EST)
Received: by qadc16 with SMTP id c16so11039764qad.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:34:02 -0800 (PST)
Message-ID: <4F000C67.7080101@gmail.com>
Date: Sun, 01 Jan 2012 02:33:59 -0500
From: KOSAKI Motohiro <kosaki.motohiro@gmail.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/5] memcg: replace MEM_CONT by MEM_RES_CTLR
References: <alpine.LSU.2.00.1112312322200.18500@eggly.anvils> <alpine.LSU.2.00.1112312326540.18500@eggly.anvils>
In-Reply-To: <alpine.LSU.2.00.1112312326540.18500@eggly.anvils>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Johannes Weiner <hannes@cmpxchg.org>, Michal Hocko <mhocko@suse.cz>, Balbir Singh <bsingharora@gmail.com>, linux-mm@kvack.org

(1/1/12 2:27 AM), Hugh Dickins wrote:
> Correct an #endif comment in memcontrol.h from MEM_CONT to MEM_RES_CTLR.
>
> Signed-off-by: Hugh Dickins<hughd@google.com>
> ---
>   include/linux/memcontrol.h |    2 +-
>   1 file changed, 1 insertion(+), 1 deletion(-)
>
> --- mmotm.orig/include/linux/memcontrol.h	2011-12-30 21:21:34.923338593 -0800
> +++ mmotm/include/linux/memcontrol.h	2011-12-30 21:21:51.939338993 -0800
> @@ -396,7 +396,7 @@ static inline void mem_cgroup_replace_pa
>   static inline void mem_cgroup_reset_owner(struct page *page)
>   {
>   }
> -#endif /* CONFIG_CGROUP_MEM_CONT */
> +#endif /* CONFIG_CGROUP_MEM_RES_CTLR */

Reviewed-by: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
