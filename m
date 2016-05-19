Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f70.google.com (mail-lf0-f70.google.com [209.85.215.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9828E6B0261
	for <linux-mm@kvack.org>; Thu, 19 May 2016 04:21:25 -0400 (EDT)
Received: by mail-lf0-f70.google.com with SMTP id m101so6848793lfi.0
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:21:25 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id w188si39050224wma.89.2016.05.19.01.21.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 19 May 2016 01:21:24 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id s63so4349818wme.2
        for <linux-mm@kvack.org>; Thu, 19 May 2016 01:21:24 -0700 (PDT)
Date: Thu, 19 May 2016 10:21:23 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: move comments for get_mctgt_type to
 proper position
Message-ID: <20160519082122.GG26110@dhcp22.suse.cz>
References: <1463644638-7446-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1463644638-7446-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Thu 19-05-16 15:57:18, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
> 
> move the comments for get_mctgt_type before the get_mctgt_type function

heh, it used to be much closer back then when introduced but we have
grown quite some code since then...

> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

> ---
>  mm/memcontrol.c | 37 +++++++++++++++++++------------------
>  1 file changed, 19 insertions(+), 18 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index fe787f5..00981d2 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4290,24 +4290,6 @@ static int mem_cgroup_do_precharge(unsigned long count)
>  	return 0;
>  }
>  
> -/**
> - * get_mctgt_type - get target type of moving charge
> - * @vma: the vma the pte to be checked belongs
> - * @addr: the address corresponding to the pte to be checked
> - * @ptent: the pte to be checked
> - * @target: the pointer the target page or swap ent will be stored(can be NULL)
> - *
> - * Returns
> - *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
> - *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
> - *     move charge. if @target is not NULL, the page is stored in target->page
> - *     with extra refcnt got(Callers should handle it).
> - *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
> - *     target for charge migration. if @target is not NULL, the entry is stored
> - *     in target->ent.
> - *
> - * Called with pte lock held.
> - */
>  union mc_target {
>  	struct page	*page;
>  	swp_entry_t	ent;
> @@ -4496,6 +4478,25 @@ out:
>  	return ret;
>  }
>  
> +/**
> + * get_mctgt_type - get target type of moving charge
> + * @vma: the vma the pte to be checked belongs
> + * @addr: the address corresponding to the pte to be checked
> + * @ptent: the pte to be checked
> + * @target: the pointer the target page or swap ent will be stored(can be NULL)
> + *
> + * Returns
> + *   0(MC_TARGET_NONE): if the pte is not a target for move charge.
> + *   1(MC_TARGET_PAGE): if the page corresponding to this pte is a target for
> + *     move charge. if @target is not NULL, the page is stored in target->page
> + *     with extra refcnt got(Callers should handle it).
> + *   2(MC_TARGET_SWAP): if the swap entry corresponding to this pte is a
> + *     target for charge migration. if @target is not NULL, the entry is stored
> + *     in target->ent.
> + *
> + * Called with pte lock held.
> + */
> +
>  static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  		unsigned long addr, pte_t ptent, union mc_target *target)
>  {
> -- 
> 2.1.4

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
