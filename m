Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 3B32C6B02C3
	for <linux-mm@kvack.org>; Fri,  1 Sep 2017 09:16:14 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id l19so276497wmi.1
        for <linux-mm@kvack.org>; Fri, 01 Sep 2017 06:16:14 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id a13si96890wrf.368.2017.09.01.06.16.12
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 01 Sep 2017 06:16:13 -0700 (PDT)
Subject: Re: [PATCH] mm/mempolicy: Remove BUG_ON() checks for VMA inside
 mpol_misplaced()
References: <b28e0081-6e10-2d55-7414-afb0574a11a1@linux.vnet.ibm.com>
 <20170901130137.7617-1-khandual@linux.vnet.ibm.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <8896e04b-9db2-53cd-cdb8-58105a94f84a@suse.cz>
Date: Fri, 1 Sep 2017 15:16:12 +0200
MIME-Version: 1.0
In-Reply-To: <20170901130137.7617-1-khandual@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Anshuman Khandual <khandual@linux.vnet.ibm.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org

On 09/01/2017 03:01 PM, Anshuman Khandual wrote:
> VMA and its address bounds checks are too late in this function.
> They must have been verified earlier in the page fault sequence.
> Hence just remove them.
> 
> Suggested-by: Vlastimil Babka <vbabka@suse.cz>
> Signed-off-by: Anshuman Khandual <khandual@linux.vnet.ibm.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mempolicy.c | 5 -----
>  1 file changed, 5 deletions(-)
> 
> diff --git a/mm/mempolicy.c b/mm/mempolicy.c
> index 618ab12..3509b84 100644
> --- a/mm/mempolicy.c
> +++ b/mm/mempolicy.c
> @@ -2172,17 +2172,12 @@ int mpol_misplaced(struct page *page, struct vm_area_struct *vma, unsigned long
>  	int polnid = -1;
>  	int ret = -1;
>  
> -	BUG_ON(!vma);
> -
>  	pol = get_vma_policy(vma, addr);
>  	if (!(pol->flags & MPOL_F_MOF))
>  		goto out;
>  
>  	switch (pol->mode) {
>  	case MPOL_INTERLEAVE:
> -		BUG_ON(addr >= vma->vm_end);
> -		BUG_ON(addr < vma->vm_start);
> -
>  		pgoff = vma->vm_pgoff;
>  		pgoff += (addr - vma->vm_start) >> PAGE_SHIFT;
>  		polnid = offset_il_node(pol, vma, pgoff);
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
