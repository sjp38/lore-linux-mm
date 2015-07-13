Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f54.google.com (mail-wg0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id 77E546B0253
	for <linux-mm@kvack.org>; Mon, 13 Jul 2015 17:12:26 -0400 (EDT)
Received: by wgxm20 with SMTP id m20so122727543wgx.3
        for <linux-mm@kvack.org>; Mon, 13 Jul 2015 14:12:26 -0700 (PDT)
Received: from johanna4.inet.fi (mta-out1.inet.fi. [62.71.2.229])
        by mx.google.com with ESMTP id a19si32068365wjr.138.2015.07.13.14.12.24
        for <linux-mm@kvack.org>;
        Mon, 13 Jul 2015 14:12:25 -0700 (PDT)
Date: Tue, 14 Jul 2015 00:07:27 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [RFC v3 2/3] mm: make optimistic check for swapin readahead
Message-ID: <20150713210727.GA1352@node.dhcp.inet.fi>
References: <1436819284-3964-1-git-send-email-ebru.akagunduz@gmail.com>
 <1436819284-3964-3-git-send-email-ebru.akagunduz@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1436819284-3964-3-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: linux-mm@kvack.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On Mon, Jul 13, 2015 at 11:28:03PM +0300, Ebru Akagunduz wrote:
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 595edd9..b4cef9d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -24,6 +24,7 @@
>  #include <linux/migrate.h>
>  #include <linux/hashtable.h>
>  #include <linux/userfaultfd_k.h>
> +#include <linux/swapops.h>
>  
>  #include <asm/tlb.h>
>  #include <asm/pgalloc.h>
> @@ -2671,11 +2672,11 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  {
>  	pmd_t *pmd;
>  	pte_t *pte, *_pte;
> -	int ret = 0, none_or_zero = 0;
> +	int ret = 0, none_or_zero = 0, unmapped = 0;
>  	struct page *page = NULL;
>  	unsigned long _address;
>  	spinlock_t *ptl;
> -	int node = NUMA_NO_NODE;
> +	int node = NUMA_NO_NODE, max_ptes_swap = HPAGE_PMD_NR/8;

So, you've decide to ignore knob request for max_ptes_swap.
Why?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
