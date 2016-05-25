Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id F2EFF6B0005
	for <linux-mm@kvack.org>; Wed, 25 May 2016 11:18:33 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id a136so30354620wme.1
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:18:33 -0700 (PDT)
Received: from mail-wm0-f66.google.com (mail-wm0-f66.google.com. [74.125.82.66])
        by mx.google.com with ESMTPS id a131si11383476wmc.4.2016.05.25.08.18.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 May 2016 08:18:32 -0700 (PDT)
Received: by mail-wm0-f66.google.com with SMTP id f75so16585736wmf.2
        for <linux-mm@kvack.org>; Wed, 25 May 2016 08:18:32 -0700 (PDT)
Date: Wed, 25 May 2016 17:18:31 +0200
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm: memcontrol: remove the useless parameter for
 mc_handle_swap_pte
Message-ID: <20160525151831.GJ20132@dhcp22.suse.cz>
References: <1464145026-26693-1-git-send-email-roy.qing.li@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1464145026-26693-1-git-send-email-roy.qing.li@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: roy.qing.li@gmail.com
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com

On Wed 25-05-16 10:57:06, roy.qing.li@gmail.com wrote:
> From: Li RongQing <roy.qing.li@gmail.com>

It is really trivial but I would add:
"
It reall seems like this parameter has never been used since introduced
by 90254a65833b ("memcg: clean up move charge"). Not a big deal
because I assume the function would get inlined into the caller anyway
but why not to get rid of it.
"
 
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>

Acked-by: Michal Hocko <mhocko@suse.com>

Thanks
> ---
>  mm/memcontrol.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index 36b7ecf..c628c90 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4386,7 +4386,7 @@ static struct page *mc_handle_present_pte(struct vm_area_struct *vma,
>  
>  #ifdef CONFIG_SWAP
>  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
> -			unsigned long addr, pte_t ptent, swp_entry_t *entry)
> +			pte_t ptent, swp_entry_t *entry)
>  {
>  	struct page *page = NULL;
>  	swp_entry_t ent = pte_to_swp_entry(ptent);
> @@ -4405,7 +4405,7 @@ static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
>  }
>  #else
>  static struct page *mc_handle_swap_pte(struct vm_area_struct *vma,
> -			unsigned long addr, pte_t ptent, swp_entry_t *entry)
> +			pte_t ptent, swp_entry_t *entry)
>  {
>  	return NULL;
>  }
> @@ -4570,7 +4570,7 @@ static enum mc_target_type get_mctgt_type(struct vm_area_struct *vma,
>  	if (pte_present(ptent))
>  		page = mc_handle_present_pte(vma, addr, ptent);
>  	else if (is_swap_pte(ptent))
> -		page = mc_handle_swap_pte(vma, addr, ptent, &ent);
> +		page = mc_handle_swap_pte(vma, ptent, &ent);
>  	else if (pte_none(ptent))
>  		page = mc_handle_file_pte(vma, addr, ptent, &ent);
>  
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
