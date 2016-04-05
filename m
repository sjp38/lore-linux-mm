Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 13CE36B0253
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 10:26:20 -0400 (EDT)
Received: by mail-qg0-f41.google.com with SMTP id c6so11477142qga.1
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 07:26:20 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id f68si26409881qge.89.2016.04.05.07.26.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 05 Apr 2016 07:26:19 -0700 (PDT)
Date: Tue, 5 Apr 2016 10:26:15 -0400
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCHv2] thp: keep huge zero page pinned until tlb flush
Message-ID: <20160405142615.GC9945@redhat.com>
References: <1459851154-112706-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1459851154-112706-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, Mel Gorman <mgorman@techsingularity.net>, Hugh Dickins <hughd@google.com>, Johannes Weiner <hannes@cmpxchg.org>, Dave Hansen <dave.hansen@intel.com>, Vlastimil Babka <vbabka@suse.cz>, linux-mm@kvack.org

On Tue, Apr 05, 2016 at 01:12:34PM +0300, Kirill A. Shutemov wrote:
> Andrea has found[1] a race condition on MMU-gather based TLB flush vs
> split_huge_page() or shrinker which frees huge zero under us (patch 1/2
> and 2/2 respectively).
> 
> With new THP refcounting, we don't need patch 1/2: mmu_gather keeps the
> page pinned until flush is complete and the pin prevents the page from
> being split under us.
> 
> We still need patch 2/2. This is simplified version of Andrea's patch.
> We don't need fancy encoding.
> 
> [1] http://lkml.kernel.org/r/1447938052-22165-1-git-send-email-aarcange@redhat.com
> 
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Reported-by: Andrea Arcangeli <aarcange@redhat.com>
> ---
>  v2:
>    - fix build for !THP;
>    - typos;
> ---
>  include/linux/huge_mm.h | 5 +++++
>  mm/huge_memory.c        | 6 +++---
>  mm/swap.c               | 5 +++++
>  3 files changed, 13 insertions(+), 3 deletions(-)

Reviewed-by: Andrea Arcangeli <aarcange@redhat.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
