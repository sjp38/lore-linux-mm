Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx197.postini.com [74.125.245.197])
	by kanga.kvack.org (Postfix) with SMTP id 1A98F6B0039
	for <linux-mm@kvack.org>; Tue, 18 Jun 2013 21:35:07 -0400 (EDT)
Message-ID: <51C10A0D.9010804@cn.fujitsu.com>
Date: Wed, 19 Jun 2013 09:31:57 +0800
From: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH v4 6/6] mm/pgtable: Don't accumulate addr during pgd prepopulate
 pmd
References: <1371599563-6424-1-git-send-email-liwanp@linux.vnet.ibm.com> <1371599563-6424-6-git-send-email-liwanp@linux.vnet.ibm.com>
In-Reply-To: <1371599563-6424-6-git-send-email-liwanp@linux.vnet.ibm.com>
Content-Transfer-Encoding: 7bit
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Wanpeng Li <liwanp@linux.vnet.ibm.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Fengguang Wu <fengguang.wu@intel.com>, Rik van Riel <riel@redhat.com>, Andrew Shewmaker <agshew@gmail.com>, Jiri Kosina <jkosina@suse.cz>, Namjae Jeon <linkinjeon@gmail.com>, Jan Kara <jack@suse.cz>, Tejun Heo <tj@kernel.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On 06/19/2013 07:52 AM, Wanpeng Li wrote:
> Changelog:
>  v2 - > v3:
>    * add Michal's Reviewed-by
> 
> The old codes accumulate addr to get right pmd, however,
> currently pmds are preallocated and transfered as a parameter,
> there is unnecessary to accumulate addr variable any more, this
> patch remove it.
> 
> Reviewed-by: Michal Hocko <mhocko@suse.cz>
> Signed-off-by: Wanpeng Li <liwanp@linux.vnet.ibm.com>

Reviewed-by: Zhang Yanfei <zhangyanfei@cn.fujitsu.com>

> ---
>  arch/x86/mm/pgtable.c |    4 +---
>  1 files changed, 1 insertions(+), 3 deletions(-)
> 
> diff --git a/arch/x86/mm/pgtable.c b/arch/x86/mm/pgtable.c
> index 17fda6a..dfa537a 100644
> --- a/arch/x86/mm/pgtable.c
> +++ b/arch/x86/mm/pgtable.c
> @@ -240,7 +240,6 @@ static void pgd_mop_up_pmds(struct mm_struct *mm, pgd_t *pgdp)
>  static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
>  {
>  	pud_t *pud;
> -	unsigned long addr;
>  	int i;
>  
>  	if (PREALLOCATED_PMDS == 0) /* Work around gcc-3.4.x bug */
> @@ -248,8 +247,7 @@ static void pgd_prepopulate_pmd(struct mm_struct *mm, pgd_t *pgd, pmd_t *pmds[])
>  
>  	pud = pud_offset(pgd, 0);
>  
> - 	for (addr = i = 0; i < PREALLOCATED_PMDS;
> -	     i++, pud++, addr += PUD_SIZE) {
> +	for (i = 0; i < PREALLOCATED_PMDS; i++, pud++) {
>  		pmd_t *pmd = pmds[i];
>  
>  		if (i >= KERNEL_PGD_BOUNDARY)


-- 
Thanks.
Zhang Yanfei

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
