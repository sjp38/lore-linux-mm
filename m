Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 43EA16B0254
	for <linux-mm@kvack.org>; Fri,  4 Sep 2015 12:18:43 -0400 (EDT)
Received: by wicfx3 with SMTP id fx3so23123099wic.0
        for <linux-mm@kvack.org>; Fri, 04 Sep 2015 09:18:42 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id r20si5108268wju.181.2015.09.04.09.18.41
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 04 Sep 2015 09:18:42 -0700 (PDT)
Subject: Re: [RESEND RFC v4 2/3] mm: make optimistic check for swapin
 readahead
References: <1441313508-4276-1-git-send-email-ebru.akagunduz@gmail.com>
 <1441313508-4276-3-git-send-email-ebru.akagunduz@gmail.com>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <55E9C45F.60407@suse.cz>
Date: Fri, 4 Sep 2015 18:18:39 +0200
MIME-Version: 1.0
In-Reply-To: <1441313508-4276-3-git-send-email-ebru.akagunduz@gmail.com>
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ebru Akagunduz <ebru.akagunduz@gmail.com>, linux-mm@kvack.org
Cc: akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, riel@redhat.com, iamjoonsoo.kim@lge.com, xiexiuqi@huawei.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, aneesh.kumar@linux.vnet.ibm.com, hughd@google.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, raindel@mellanox.com

On 09/03/2015 10:51 PM, Ebru Akagunduz wrote:
> This patch introduces new sysfs integer knob
> /sys/kernel/mm/transparent_hugepage/khugepaged/max_ptes_swap
> which makes optimistic check for swapin readahead to
> increase thp collapse rate. Before getting swapped
> out pages to memory, checks them and allows up to a
> certain number. It also prints out using tracepoints
> amount of unmapped ptes.
> 
> Signed-off-by: Ebru Akagunduz <ebru.akagunduz@gmail.com>

...

>  #include <asm/pgalloc.h>
> @@ -49,7 +50,8 @@ static const char *const khugepaged_status_string[] = {
>  	"page_swap_cache",
>  	"could_not_delete_page_from_lru",
>  	"alloc_huge_page_fail",
> -	"ccgroup_charge_fail"
> +	"ccgroup_charge_fail",
> +	"exceed_swap_pte"
>  };
>  
>  enum scan_result {
> @@ -73,7 +75,8 @@ enum scan_result {
>  	SCAN_SWAP_CACHE_PAGE,
>  	SCAN_DEL_PAGE_LRU,
>  	SCAN_ALLOC_HUGE_PAGE_FAIL,
> -	SCAN_CGROUP_CHARGE_FAIL
> +	SCAN_CGROUP_CHARGE_FAIL,
> +	MM_EXCEED_SWAP_PTE

This one should be renamed too.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
