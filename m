Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id 0A4236B0031
	for <linux-mm@kvack.org>; Wed, 24 Jul 2013 07:45:20 -0400 (EDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
In-Reply-To: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
References: <1374637699-25704-1-git-send-email-huawei.libin@huawei.com>
Subject: RE: [PATCH] mm: Fix potential NULL pointer dereference
Content-Transfer-Encoding: 7bit
Message-Id: <20130724114829.61EF3E0090@blue.fi.intel.com>
Date: Wed, 24 Jul 2013 14:48:29 +0300 (EEST)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Libin <huawei.libin@huawei.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, mgorman@suse.de, xiaoguangrong@linux.vnet.ibm.com, wujianguo@huawei.com

Libin wrote:
> find_vma may return NULL, thus check the return
> value to avoid NULL pointer dereference.
> 
> Signed-off-by: Libin <huawei.libin@huawei.com>

Looks correct to me.

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

Have you ever triggered the race or just found it by reading the code?
I wounder if it's subject for stable@.

> ---
>  mm/huge_memory.c | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 243e710..d4423f4 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2294,6 +2294,8 @@ static void collapse_huge_page(struct mm_struct *mm,
>  		goto out;
>  
>  	vma = find_vma(mm, address);
> +	if (!vma)
> +		goto out;
>  	hstart = (vma->vm_start + ~HPAGE_PMD_MASK) & HPAGE_PMD_MASK;
>  	hend = vma->vm_end & HPAGE_PMD_MASK;
>  	if (address < hstart || address + HPAGE_PMD_SIZE > hend)
> -- 
> 1.8.2.1

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
