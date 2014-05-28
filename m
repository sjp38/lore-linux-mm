Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 9C1096B0037
	for <linux-mm@kvack.org>; Wed, 28 May 2014 03:44:38 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so3179546wib.5
        for <linux-mm@kvack.org>; Wed, 28 May 2014 00:44:38 -0700 (PDT)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id j8si30121522wje.75.2014.05.28.00.44.36
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 28 May 2014 00:44:37 -0700 (PDT)
Date: Wed, 28 May 2014 09:44:36 +0200
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH mmotm/next]
 vmscan-memcg-always-use-swappiness-of-the-reclaimed-memcg-swappiness-and-o
 om-control-fix.patch
Message-ID: <20140528074436.GB9895@dhcp22.suse.cz>
References: <alpine.LSU.2.11.1405271432400.4485@eggly.anvils>
 <alpine.LSU.2.11.1405271436200.4485@eggly.anvils>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LSU.2.11.1405271436200.4485@eggly.anvils>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hugh Dickins <hughd@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Johannes Weiner <hannes@cmpxchg.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Tue 27-05-14 14:38:40, Hugh Dickins wrote:
> mem_cgroup_swappiness() oopses immediately when
> booted with cgroup_disable=memory.  Fix that in the obvious inelegant
> way for now - though I hope we are moving towards a world in which
> almost all of the mem_cgroup_disabled() tests will vanish, with a
> root_mem_cgroup which can handle the basics even when disabled.
> 
> Signed-off-by: Hugh Dickins <hughd@google.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

Thanks!

> ---
> 
>  mm/memcontrol.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> --- mmotm/mm/memcontrol.c	2014-05-21 18:12:18.072022438 -0700
> +++ linux/mm/memcontrol.c	2014-05-21 19:34:30.608546905 -0700
> @@ -1531,7 +1531,7 @@ static unsigned long mem_cgroup_margin(s
>  int mem_cgroup_swappiness(struct mem_cgroup *memcg)
>  {
>  	/* root ? */
> -	if (!memcg->css.parent)
> +	if (mem_cgroup_disabled() || !memcg->css.parent)
>  		return vm_swappiness;
>  
>  	return memcg->swappiness;

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
