Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx141.postini.com [74.125.245.141])
	by kanga.kvack.org (Postfix) with SMTP id AED716B0031
	for <linux-mm@kvack.org>; Mon,  9 Sep 2013 21:29:13 -0400 (EDT)
Received: from m3.gw.fujitsu.co.jp (unknown [10.0.50.73])
	by fgwmail6.fujitsu.co.jp (Postfix) with ESMTP id C13AE3EE0C2
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:29:11 +0900 (JST)
Received: from smail (m3 [127.0.0.1])
	by outgoing.m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 93E7845DEBC
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:29:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (s3.gw.fujitsu.co.jp [10.0.50.93])
	by m3.gw.fujitsu.co.jp (Postfix) with ESMTP id 7C95745DEBA
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:29:11 +0900 (JST)
Received: from s3.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 70976E18005
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:29:11 +0900 (JST)
Received: from g01jpfmpwkw03.exch.g01.fujitsu.local (g01jpfmpwkw03.exch.g01.fujitsu.local [10.0.193.57])
	by s3.gw.fujitsu.co.jp (Postfix) with ESMTP id 2955A1DB803B
	for <linux-mm@kvack.org>; Tue, 10 Sep 2013 10:29:11 +0900 (JST)
Message-ID: <522E75BE.4080505@jp.fujitsu.com>
Date: Tue, 10 Sep 2013 10:28:30 +0900
From: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
MIME-Version: 1.0
Subject: Re: [PATCH 1/2] mm: thp: cleanup: mv alloc_hugepage to better place
References: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
In-Reply-To: <1378093542-31971-1-git-send-email-bob.liu@oracle.com>
Content-Type: text/plain; charset="ISO-2022-JP"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Bob Liu <lliubbo@gmail.com>
Cc: akpm@linux-foundation.org, linux-mm@kvack.org, aarcange@redhat.com, kirill.shutemov@linux.intel.com, mgorman@suse.de, konrad.wilk@oracle.com, davidoff@qedmf.net, Bob Liu <bob.liu@oracle.com>

(2013/09/02 12:45), Bob Liu wrote:
> Move alloc_hugepage to better place, no need for a seperate #ifndef CONFIG_NUMA
> 
> Signed-off-by: Bob Liu <bob.liu@oracle.com>
> ---

Reviewed-by: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>

Thanks,
Yasuaki Ishimatsu

>   mm/huge_memory.c |   14 ++++++--------
>   1 file changed, 6 insertions(+), 8 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index a92012a..7448cf9 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -753,14 +753,6 @@ static inline struct page *alloc_hugepage_vma(int defrag,
>   			       HPAGE_PMD_ORDER, vma, haddr, nd);
>   }
>   
> -#ifndef CONFIG_NUMA
> -static inline struct page *alloc_hugepage(int defrag)
> -{
> -	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> -			   HPAGE_PMD_ORDER);
> -}
> -#endif
> -
>   static bool set_huge_zero_page(pgtable_t pgtable, struct mm_struct *mm,
>   		struct vm_area_struct *vma, unsigned long haddr, pmd_t *pmd,
>   		struct page *zero_page)
> @@ -2204,6 +2196,12 @@ static struct page
>   	return *hpage;
>   }
>   #else
> +static inline struct page *alloc_hugepage(int defrag)
> +{
> +	return alloc_pages(alloc_hugepage_gfpmask(defrag, 0),
> +			   HPAGE_PMD_ORDER);
> +}
> +
>   static struct page *khugepaged_alloc_hugepage(bool *wait)
>   {
>   	struct page *hpage;
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
