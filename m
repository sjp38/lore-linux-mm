Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f42.google.com (mail-qa0-f42.google.com [209.85.216.42])
	by kanga.kvack.org (Postfix) with ESMTP id 097F06B003C
	for <linux-mm@kvack.org>; Tue,  1 Jul 2014 13:52:58 -0400 (EDT)
Received: by mail-qa0-f42.google.com with SMTP id dc16so8110805qab.29
        for <linux-mm@kvack.org>; Tue, 01 Jul 2014 10:52:57 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id c5si3676322qar.73.2014.07.01.10.52.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 01 Jul 2014 10:52:57 -0700 (PDT)
Date: Tue, 1 Jul 2014 10:05:08 -0400
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: Re: [patch] mm, hugetlb: remove hugetlb_zero and hugetlb_infinity
Message-ID: <20140701140508.GA12661@nhori.bos.redhat.com>
References: <alpine.DEB.2.02.1406301655480.27587@chino.kir.corp.google.com>
 <alpine.DEB.2.02.1406301745200.7070@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.02.1406301745200.7070@chino.kir.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Luiz Capitulino <lcapitulino@redhat.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Jun 30, 2014 at 05:46:35PM -0700, David Rientjes wrote:
> They are unnecessary: "zero" can be used in place of "hugetlb_zero" and 
> passing extra2 == NULL is equivalent to infinity.
> 
> Signed-off-by: David Rientjes <rientjes@google.com>

Reviewed-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>

> ---
>  include/linux/hugetlb.h | 1 -
>  kernel/sysctl.c         | 9 +++------
>  mm/hugetlb.c            | 1 -
>  3 files changed, 3 insertions(+), 8 deletions(-)
> 
> diff --git a/include/linux/hugetlb.h b/include/linux/hugetlb.h
> --- a/include/linux/hugetlb.h
> +++ b/include/linux/hugetlb.h
> @@ -86,7 +86,6 @@ pte_t *huge_pmd_share(struct mm_struct *mm, unsigned long addr, pud_t *pud);
>  #endif
>  
>  extern unsigned long hugepages_treat_as_movable;
> -extern const unsigned long hugetlb_zero, hugetlb_infinity;
>  extern int sysctl_hugetlb_shm_group;
>  extern struct list_head huge_boot_pages;
>  
> diff --git a/kernel/sysctl.c b/kernel/sysctl.c
> --- a/kernel/sysctl.c
> +++ b/kernel/sysctl.c
> @@ -1240,8 +1240,7 @@ static struct ctl_table vm_table[] = {
>  		.maxlen		= sizeof(unsigned long),
>  		.mode		= 0644,
>  		.proc_handler	= hugetlb_sysctl_handler,
> -		.extra1		= (void *)&hugetlb_zero,
> -		.extra2		= (void *)&hugetlb_infinity,
> +		.extra1		= &zero,
>  	},
>  #ifdef CONFIG_NUMA
>  	{
> @@ -1250,8 +1249,7 @@ static struct ctl_table vm_table[] = {
>  		.maxlen         = sizeof(unsigned long),
>  		.mode           = 0644,
>  		.proc_handler   = &hugetlb_mempolicy_sysctl_handler,
> -		.extra1		= (void *)&hugetlb_zero,
> -		.extra2		= (void *)&hugetlb_infinity,
> +		.extra1		= &zero,
>  	},
>  #endif
>  	 {
> @@ -1274,8 +1272,7 @@ static struct ctl_table vm_table[] = {
>  		.maxlen		= sizeof(unsigned long),
>  		.mode		= 0644,
>  		.proc_handler	= hugetlb_overcommit_handler,
> -		.extra1		= (void *)&hugetlb_zero,
> -		.extra2		= (void *)&hugetlb_infinity,
> +		.extra1		= &zero,
>  	},
>  #endif
>  	{
> diff --git a/mm/hugetlb.c b/mm/hugetlb.c
> --- a/mm/hugetlb.c
> +++ b/mm/hugetlb.c
> @@ -35,7 +35,6 @@
>  #include <linux/node.h>
>  #include "internal.h"
>  
> -const unsigned long hugetlb_zero = 0, hugetlb_infinity = ~0UL;
>  unsigned long hugepages_treat_as_movable;
>  
>  int hugetlb_max_hstate __read_mostly;
> 
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
