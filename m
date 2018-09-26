Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ed1-f71.google.com (mail-ed1-f71.google.com [209.85.208.71])
	by kanga.kvack.org (Postfix) with ESMTP id E3A8E8E0001
	for <linux-mm@kvack.org>; Wed, 26 Sep 2018 07:13:15 -0400 (EDT)
Received: by mail-ed1-f71.google.com with SMTP id x24-v6so1117050edm.13
        for <linux-mm@kvack.org>; Wed, 26 Sep 2018 04:13:15 -0700 (PDT)
Received: from mx1.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id n4-v6si18911425eda.62.2018.09.26.04.13.14
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 26 Sep 2018 04:13:14 -0700 (PDT)
Subject: Re: [v11 PATCH 2/3] mm: unmap VM_HUGETLB mappings with optimized path
References: <1537376621-51150-1-git-send-email-yang.shi@linux.alibaba.com>
 <1537376621-51150-3-git-send-email-yang.shi@linux.alibaba.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <88f0a142-a263-858d-83af-dc9abfc5bad8@suse.cz>
Date: Wed, 26 Sep 2018 13:10:36 +0200
MIME-Version: 1.0
In-Reply-To: <1537376621-51150-3-git-send-email-yang.shi@linux.alibaba.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>, mhocko@kernel.org, willy@infradead.org, ldufour@linux.vnet.ibm.com, kirill@shutemov.name, akpm@linux-foundation.org
Cc: dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 9/19/18 7:03 PM, Yang Shi wrote:
> When unmapping VM_HUGETLB mappings, vm flags need to be updated. Since
> the vmas have been detached, so it sounds safe to update vm flags with
> read mmap_sem.
> 
> Cc: Michal Hocko <mhocko@kernel.org>
> Cc: Vlastimil Babka <vbabka@suse.cz>
> Reviewed-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Yang Shi <yang.shi@linux.alibaba.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> ---
>  mm/mmap.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/mmap.c b/mm/mmap.c
> index 982dd00..490340e 100644
> --- a/mm/mmap.c
> +++ b/mm/mmap.c
> @@ -2777,7 +2777,7 @@ static int __do_munmap(struct mm_struct *mm, unsigned long start, size_t len,
>  			 * update vm_flags.
>  			 */
>  			if (downgrade &&
> -			    (tmp->vm_flags & (VM_HUGETLB | VM_PFNMAP)))
> +			    (tmp->vm_flags & VM_PFNMAP))
>  				downgrade = false;
>  
>  			tmp = tmp->vm_next;
> 
