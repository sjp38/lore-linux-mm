Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 472CF6B02AB
	for <linux-mm@kvack.org>; Wed,  2 Nov 2016 00:18:18 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id rf5so2308586pab.3
        for <linux-mm@kvack.org>; Tue, 01 Nov 2016 21:18:18 -0700 (PDT)
Received: from out0-144.mail.aliyun.com (out0-144.mail.aliyun.com. [140.205.0.144])
        by mx.google.com with ESMTP id 10si284652pac.258.2016.11.01.21.18.16
        for <linux-mm@kvack.org>;
        Tue, 01 Nov 2016 21:18:17 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <1478039794-20253-1-git-send-email-jack@suse.cz> <1478039794-20253-5-git-send-email-jack@suse.cz>
In-Reply-To: <1478039794-20253-5-git-send-email-jack@suse.cz>
Subject: Re: [PATCH 02/21] mm: Use vmf->address instead of of vmf->virtual_address
Date: Wed, 02 Nov 2016 12:18:10 +0800
Message-ID: <06aa01d234c0$1f85e700$5e91b500$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Jan Kara' <jack@suse.cz>, linux-mm@kvack.org
Cc: linux-fsdevel@vger.kernel.org, linux-nvdimm@lists.01.org, 'Andrew Morton' <akpm@linux-foundation.org>, 'Ross Zwisler' <ross.zwisler@linux.intel.com>

On Wednesday, November 02, 2016 6:36 AM Jan Kara wrote:
> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index 8e8b76d11bb4..2a4ebe3c67c6 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -297,8 +297,6 @@ struct vm_fault {
>  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
>  	unsigned long address;		/* Faulting virtual address */
> -	void __user *virtual_address;	/* Faulting virtual address masked by
> -					 * PAGE_MASK */
>  	pmd_t *pmd;			/* Pointer to pmd entry matching
>  					 * the 'address'
>  					 */
We have a pmd field currently?

In  [PATCH 01/20] mm: Change type of vmf->virtual_address we see
[1] __user * gone,
[2] no field of address added
and doubt stray merge occurred.

btw, s:01/20:01/21: in subject line?

Hillf

> diff --git a/include/linux/mm.h b/include/linux/mm.h
> index ef815b9cd426..a5636d646022 100644
> --- a/include/linux/mm.h
> +++ b/include/linux/mm.h
> @@ -295,7 +295,7 @@ struct vm_fault {
>  	unsigned int flags;		/* FAULT_FLAG_xxx flags */
>  	gfp_t gfp_mask;			/* gfp mask to be used for allocations */
>  	pgoff_t pgoff;			/* Logical page offset based on vma */
> -	void __user *virtual_address;	/* Faulting virtual address */
> +	unsigned long virtual_address;	/* Faulting virtual address */
> 
>  	struct page *cow_page;		/* Handler may choose to COW */
>  	struct page *page;		/* ->fault handlers should return a


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
