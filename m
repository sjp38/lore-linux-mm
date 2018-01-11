Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id CAF806B025F
	for <linux-mm@kvack.org>; Thu, 11 Jan 2018 05:06:28 -0500 (EST)
Received: by mail-wm0-f72.google.com with SMTP id a141so1163472wma.8
        for <linux-mm@kvack.org>; Thu, 11 Jan 2018 02:06:28 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id u136si351721wmf.233.2018.01.11.02.06.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 11 Jan 2018 02:06:27 -0800 (PST)
Date: Thu, 11 Jan 2018 11:06:20 +0100
From: Michal Hocko <mhocko@kernel.org>
Subject: Re: [PATCH] mm, THP: vmf_insert_pfn_pud depends on
 CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
Message-ID: <20180111100620.GY1732@dhcp22.suse.cz>
References: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1515660811-12293-1-git-send-email-aghiti@upmem.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexandre Ghiti <aghiti@upmem.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, dan.j.williams@intel.com, zi.yan@cs.rutgers.edu, gregkh@linuxfoundation.org, n-horiguchi@ah.jp.nec.com, willy@linux.intel.com, mark.rutland@arm.com, linux-kernel@vger.kernel.org

On Thu 11-01-18 09:53:31, Alexandre Ghiti wrote:
> The only definition of vmf_insert_pfn_pud depends on
> CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD being defined. Then its declaration in
> include/linux/huge_mm.h should have the same restriction so that we do
> not expose this function if CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD is
> not defined.

Why is this a problem? Compiler should simply throw away any
declarations which are not used?

> Signed-off-by: Alexandre Ghiti <aghiti@upmem.com>
> ---
>  include/linux/huge_mm.h | 2 ++
>  1 file changed, 2 insertions(+)
> 
> diff --git a/include/linux/huge_mm.h b/include/linux/huge_mm.h
> index a8a1262..11794f6a 100644
> --- a/include/linux/huge_mm.h
> +++ b/include/linux/huge_mm.h
> @@ -48,8 +48,10 @@ extern int change_huge_pmd(struct vm_area_struct *vma, pmd_t *pmd,
>  			int prot_numa);
>  int vmf_insert_pfn_pmd(struct vm_area_struct *vma, unsigned long addr,
>  			pmd_t *pmd, pfn_t pfn, bool write);
> +#ifdef CONFIG_HAVE_ARCH_TRANSPARENT_HUGEPAGE_PUD
>  int vmf_insert_pfn_pud(struct vm_area_struct *vma, unsigned long addr,
>  			pud_t *pud, pfn_t pfn, bool write);
> +#endif
>  enum transparent_hugepage_flag {
>  	TRANSPARENT_HUGEPAGE_FLAG,
>  	TRANSPARENT_HUGEPAGE_REQ_MADV_FLAG,
> -- 
> 2.1.4
> 

-- 
Michal Hocko
SUSE Labs

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
