Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id A33F96B0038
	for <linux-mm@kvack.org>; Fri, 17 Apr 2015 03:12:06 -0400 (EDT)
Received: by pabtp1 with SMTP id tp1so116419215pab.2
        for <linux-mm@kvack.org>; Fri, 17 Apr 2015 00:12:06 -0700 (PDT)
Received: from out21.biz.mail.alibaba.com (out114-136.biz.mail.alibaba.com. [205.204.114.136])
        by mx.google.com with ESMTP id ku2si15418238pbc.235.2015.04.17.00.12.04
        for <linux-mm@kvack.org>;
        Fri, 17 Apr 2015 00:12:05 -0700 (PDT)
Reply-To: "Hillf Danton" <hillf.zj@alibaba-inc.com>
From: "Hillf Danton" <hillf.zj@alibaba-inc.com>
References: <00e601d078da$9e762190$db6264b0$@alibaba-inc.com>
In-Reply-To: <00e601d078da$9e762190$db6264b0$@alibaba-inc.com>
Subject: Re: [RFC PATCH 4/4] mm: madvise allow remove operation for hugetlbfs
Date: Fri, 17 Apr 2015 15:10:29 +0800
Message-ID: <00ef01d078dd$96bfc480$c43f4d80$@alibaba-inc.com>
MIME-Version: 1.0
Content-Type: text/plain;
	charset="UTF-8"
Content-Transfer-Encoding: 7bit
Content-Language: zh-cn
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: 'Dave Hansen' <dave.hansen@linux.intel.com>, 'Mike Kravetz' <mike.kravetz@oracle.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, Michal Hocko <mhocko@suse.cz>

> 
> Now that we have hole punching support for hugetlbfs, we can
> also support the MADV_REMOVE interface to it.
> 
> Signed-off-by: Dave Hansen <dave.hansen@linux.intel.com>
> Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
> ---
>  mm/madvise.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/madvise.c b/mm/madvise.c
> index d551475..c4a1027 100644
> --- a/mm/madvise.c
> +++ b/mm/madvise.c
> @@ -299,7 +299,7 @@ static long madvise_remove(struct vm_area_struct *vma,
> 
>  	*prev = NULL;	/* tell sys_madvise we drop mmap_sem */
> 
> -	if (vma->vm_flags & (VM_LOCKED | VM_HUGETLB))
> +	if (vma->vm_flags & VM_LOCKED)
>  		return -EINVAL;
> 
>  	f = vma->vm_file;
> --
> 2.1.0

After the above change offset is computed,

	offset = (loff_t)(start - vma->vm_start)
		+ ((loff_t)vma->vm_pgoff << PAGE_SHIFT);

and I wonder if it is correct for huge page mapping.

Hillf

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
