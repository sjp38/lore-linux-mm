Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 1B2CB6B0031
	for <linux-mm@kvack.org>; Tue,  6 Aug 2013 08:16:47 -0400 (EDT)
Date: Tue, 6 Aug 2013 14:16:42 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: +
 memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch added
 to -mm tree
Message-ID: <20130806121642.GB31138@dhcp22.suse.cz>
References: <52000596.PaFYoOeTZYatCvLY%akpm@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <52000596.PaFYoOeTZYatCvLY%akpm@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: mm-commits@vger.kernel.org, stable@vger.kernel.org, khlebnikov@openvz.org, kamezawa.hiroyu@jp.fujitsu.com, hannes@cmpxchg.org, glommer@openvz.org, bsingharora@gmail.com, avagin@openvz.org, linux-mm@kvack.org

On Mon 05-08-13 13:05:42, Andrew Morton wrote:
> Subject: + memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch added to -mm tree
> To: avagin@openvz.org,bsingharora@gmail.com,glommer@openvz.org,hannes@cmpxchg.org,kamezawa.hiroyu@jp.fujitsu.com,khlebnikov@openvz.org,mhocko@suse.cz,stable@vger.kernel.org
> From: akpm@linux-foundation.org
> Date: Mon, 05 Aug 2013 13:05:42 -0700
> 
> 
> The patch titled
>      Subject: memcg: don't initialize kmem-cache destroying work for root caches
> has been added to the -mm tree.  Its filename is
>      memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
> 
> This patch should soon appear at
>     http://ozlabs.org/~akpm/mmots/broken-out/memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
> and later at
>     http://ozlabs.org/~akpm/mmotm/broken-out/memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
> 
> Before you just go and hit "reply", please:
>    a) Consider who else should be cc'ed
>    b) Prefer to cc a suitable mailing list as well
>    c) Ideally: find the original patch on the mailing list and do a
>       reply-to-all to that, adding suitable additional cc's
> 
> *** Remember to use Documentation/SubmitChecklist when testing your code ***
> 
> The -mm tree is included into linux-next and is updated
> there every 3-4 working days
> 
> ------------------------------------------------------
> From: Andrey Vagin <avagin@openvz.org>
> Subject: memcg: don't initialize kmem-cache destroying work for root caches
> 
> struct memcg_cache_params has a union.  Different parts of this union are
> used for root and non-root caches.  A part with destroying work is used
> only for non-root caches.
> 
> I fixed the same problem in another place v3.9-rc1-16204-gf101a94, but
> didn't notice this one.
> 
> Signed-off-by: Andrey Vagin <avagin@openvz.org>
> Cc: Glauber Costa <glommer@openvz.org>
> Cc: Johannes Weiner <hannes@cmpxchg.org>
> Cc: Michal Hocko <mhocko@suse.cz>
> Cc: Balbir Singh <bsingharora@gmail.com>
> Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> Cc: Konstantin Khlebnikov <khlebnikov@openvz.org>
> Cc: <stable@vger.kernel.org>    [3.9.x]
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
> 
>  mm/memcontrol.c |    4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
> 
> diff -puN mm/memcontrol.c~memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches mm/memcontrol.c
> --- a/mm/memcontrol.c~memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches
> +++ a/mm/memcontrol.c
> @@ -3195,11 +3195,11 @@ int memcg_register_cache(struct mem_cgro
>  	if (!s->memcg_params)
>  		return -ENOMEM;
>  
> -	INIT_WORK(&s->memcg_params->destroy,
> -			kmem_cache_destroy_work_func);
>  	if (memcg) {
>  		s->memcg_params->memcg = memcg;
>  		s->memcg_params->root_cache = root_cache;
> +		INIT_WORK(&s->memcg_params->destroy,
> +				kmem_cache_destroy_work_func);
>  	} else
>  		s->memcg_params->is_root_cache = true;
>  
> _
> 
> Patches currently in -mm which might be from avagin@openvz.org are
> 
> memcg-dont-initialize-kmem-cache-destroying-work-for-root-caches.patch
> move-exit_task_namespaces-outside-of-exit_notify-fix.patch
> procfs-remove-extra-call-of-dir_emit_dots.patch
> linux-next.patch
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
