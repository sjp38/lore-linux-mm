Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f172.google.com (mail-we0-f172.google.com [74.125.82.172])
	by kanga.kvack.org (Postfix) with ESMTP id CAE516B0032
	for <linux-mm@kvack.org>; Mon, 26 Jan 2015 08:37:36 -0500 (EST)
Received: by mail-we0-f172.google.com with SMTP id q59so9074905wes.3
        for <linux-mm@kvack.org>; Mon, 26 Jan 2015 05:37:36 -0800 (PST)
Received: from mx2.suse.de (cantor2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id gl9si20504511wjc.3.2015.01.26.05.37.34
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Mon, 26 Jan 2015 05:37:35 -0800 (PST)
Date: Mon, 26 Jan 2015 14:37:33 +0100
From: Michal Hocko <mhocko@suse.cz>
Subject: Re: [PATCH] memcg: fix static checker warning
Message-ID: <20150126133733.GA22689@dhcp22.suse.cz>
References: <1422276248-40456-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1422276248-40456-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon 26-01-15 14:44:08, Kirill A. Shutemov wrote:
> The patch "mm: remove rest usage of VM_NONLINEAR and pte_file()" from
> Jan 17, 2015, leads to the following static checker warning:
> 
>         mm/memcontrol.c:4794 mc_handle_file_pte()
>         warn: passing uninitialized 'pgoff'
> 
> After the patch, the only case when mc_handle_file_pte() called is
> pte_none(ptent). The 'if' check is redundant and lead to the warning.
> Let's drop it.
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Michal Hocko <mhocko@suse.cz>

> ---
>  mm/memcontrol.c | 3 +--
>  1 file changed, 1 insertion(+), 2 deletions(-)
> 
> diff --git a/mm/memcontrol.c b/mm/memcontrol.c
> index cd42f14d138a..a6140c0764f4 100644
> --- a/mm/memcontrol.c
> +++ b/mm/memcontrol.c
> @@ -4792,8 +4792,7 @@ static struct page *mc_handle_file_pte(struct vm_area_struct *vma,
>  		return NULL;
>  
>  	mapping = vma->vm_file->f_mapping;
> -	if (pte_none(ptent))
> -		pgoff = linear_page_index(vma, addr);
> +	pgoff = linear_page_index(vma, addr);
>  
>  	/* page is moved even if it's not RSS of this task(page-faulted). */
>  #ifdef CONFIG_SWAP
> -- 
> 2.1.4
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
