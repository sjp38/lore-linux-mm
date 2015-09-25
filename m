Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id D67246B0253
	for <linux-mm@kvack.org>; Fri, 25 Sep 2015 02:43:07 -0400 (EDT)
Received: by wiclk2 with SMTP id lk2so6430375wic.1
        for <linux-mm@kvack.org>; Thu, 24 Sep 2015 23:43:07 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id bb3si2659559wib.77.2015.09.24.23.43.06
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 24 Sep 2015 23:43:06 -0700 (PDT)
Subject: Re: [patch] mm/huge_memory: add a missing tab
References: <20150921162314.GB5648@mwanda>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <5604ECF7.7000002@suse.cz>
Date: Fri, 25 Sep 2015 08:43:03 +0200
MIME-Version: 1.0
In-Reply-To: <20150921162314.GB5648@mwanda>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Carpenter <dan.carpenter@oracle.com>, Andrew Morton <akpm@linux-foundation.org>, Ebru Akagunduz <ebru.akagunduz@gmail.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Matthew Wilcox <willy@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org, kernel-janitors@vger.kernel.org

On 09/21/2015 06:23 PM, Dan Carpenter wrote:
> This line should be indented one more tab.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Acked-by: Vlastimil Babka <vbabka@suse.cz>

> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 4b057ab..61d2162 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -2887,7 +2887,7 @@ static int khugepaged_scan_pmd(struct mm_struct *mm,
>  		khugepaged_node_load[node]++;
>  		VM_BUG_ON_PAGE(PageCompound(page), page);
>  		if (!PageLRU(page)) {
> -		result = SCAN_SCAN_ABORT;
> +			result = SCAN_SCAN_ABORT;
>  			goto out_unmap;
>  		}
>  		if (PageLocked(page)) {
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
