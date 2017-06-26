Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 9C3126B0292
	for <linux-mm@kvack.org>; Mon, 26 Jun 2017 05:36:30 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id j85so306877wmj.2
        for <linux-mm@kvack.org>; Mon, 26 Jun 2017 02:36:30 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id c47si11664504wrc.110.2017.06.26.02.36.28
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 26 Jun 2017 02:36:29 -0700 (PDT)
Subject: Re: [PATCH 1/6] MIPS: do not use __GFP_REPEAT for order-0 request
References: <20170623085345.11304-1-mhocko@kernel.org>
 <20170623085345.11304-2-mhocko@kernel.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <6d938406-2af2-2d01-4a83-fd88f7271e7d@suse.cz>
Date: Mon, 26 Jun 2017 11:36:27 +0200
MIME-Version: 1.0
In-Reply-To: <20170623085345.11304-2-mhocko@kernel.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Mel Gorman <mgorman@suse.de>, NeilBrown <neilb@suse.com>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.com>, Alex Belits <alex.belits@cavium.com>, David Daney <david.daney@cavium.com>, Ralf Baechle <ralf@linux-mips.org>

On 06/23/2017 10:53 AM, Michal Hocko wrote:
> From: Michal Hocko <mhocko@suse.com>
> 
> 3377e227af44 ("MIPS: Add 48-bit VA space (and 4-level page tables) for
> 4K pages.") has added a new __GFP_REPEAT user but using this flag
> doesn't really make any sense for order-0 request which is the case here
> because PUD_ORDER is 0. __GFP_REPEAT has historically effect only on
> allocation requests with order > PAGE_ALLOC_COSTLY_ORDER.
> 
> This doesn't introduce any functional change. This is a preparatory
> patch for later work which renames the flag and redefines its semantic.
> 
> Cc: Alex Belits <alex.belits@cavium.com>
> Cc: David Daney <david.daney@cavium.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Michal Hocko <mhocko@suse.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  arch/mips/include/asm/pgalloc.h | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/arch/mips/include/asm/pgalloc.h b/arch/mips/include/asm/pgalloc.h
> index a1bdb1ea5234..39b9f311c4ef 100644
> --- a/arch/mips/include/asm/pgalloc.h
> +++ b/arch/mips/include/asm/pgalloc.h
> @@ -116,7 +116,7 @@ static inline pud_t *pud_alloc_one(struct mm_struct *mm, unsigned long address)
>  {
>  	pud_t *pud;
>  
> -	pud = (pud_t *) __get_free_pages(GFP_KERNEL|__GFP_REPEAT, PUD_ORDER);
> +	pud = (pud_t *) __get_free_pages(GFP_KERNEL, PUD_ORDER);
>  	if (pud)
>  		pud_init((unsigned long)pud, (unsigned long)invalid_pmd_table);
>  	return pud;
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
