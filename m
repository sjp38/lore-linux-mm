Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f44.google.com (mail-wg0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 4FEF36B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:29:16 -0500 (EST)
Received: by mail-wg0-f44.google.com with SMTP id l18so4171238wgh.23
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:29:15 -0800 (PST)
Received: from mail-wg0-x230.google.com (mail-wg0-x230.google.com [2a00:1450:400c:c00::230])
        by mx.google.com with ESMTPS id fb6si6881942wic.38.2014.02.10.06.29.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 10 Feb 2014 06:29:14 -0800 (PST)
Received: by mail-wg0-f48.google.com with SMTP id x13so4262603wgg.27
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 06:29:13 -0800 (PST)
Date: Mon, 10 Feb 2014 15:29:11 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [patch 5/8] memcg: remove unnecessary !mm check from
 try_get_mem_cgroup_from_mm()
Message-ID: <20140210142911.GJ7117@dhcp22.suse.cz>
References: <1391792665-21678-1-git-send-email-hannes@cmpxchg.org>
 <1391792665-21678-6-git-send-email-hannes@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1391792665-21678-6-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri 07-02-14 12:04:22, Johannes Weiner wrote:
> Users pass either a mm that has been established under task lock, or
> use a verified current->mm, which means the task can't be exiting.
> 
> Signed-off-by: Johannes Weiner <hannes@cmpxchg.org>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 7 -------
>  1 file changed, 7 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index e1d7f33227e4..689fffdee471 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -1075,13 +1075,6 @@ struct mem_cgroup *try_get_mem_cgroup_from_mm(struct mm_struct *mm)
>  {
>  	struct mem_cgroup *memcg = NULL;
>  
> -	if (!mm)
> -		return NULL;
> -	/*
> -	 * Because we have no locks, mm->owner's may be being moved to other
> -	 * cgroup. We use css_tryget() here even if this looks
> -	 * pessimistic (rather than adding locks here).
> -	 */
>  	rcu_read_lock();
>  	do {
>  		memcg = mem_cgroup_from_task(rcu_dereference(mm->owner));
> -- 
> 1.8.5.3
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
