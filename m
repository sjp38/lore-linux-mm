Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f69.google.com (mail-lf0-f69.google.com [209.85.215.69])
	by kanga.kvack.org (Postfix) with ESMTP id 386626B000A
	for <linux-mm@kvack.org>; Wed,  2 May 2018 19:45:21 -0400 (EDT)
Received: by mail-lf0-f69.google.com with SMTP id h82-v6so5118163lfi.8
        for <linux-mm@kvack.org>; Wed, 02 May 2018 16:45:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id z189-v6sor2713460lfa.14.2018.05.02.16.45.19
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 02 May 2018 16:45:19 -0700 (PDT)
Date: Wed, 2 May 2018 11:12:17 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH v4 13/16] mm: Add pt_mm to struct page
Message-ID: <20180502081217.guqf6phmwnnw5t2q@kshutemo-mobl1>
References: <20180430202247.25220-1-willy@infradead.org>
 <20180430202247.25220-14-willy@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180430202247.25220-14-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: linux-mm@kvack.org, Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Vlastimil Babka <vbabka@suse.cz>, Dave Hansen <dave.hansen@linux.intel.com>, =?utf-8?B?SsOpcsO0bWU=?= Glisse <jglisse@redhat.com>

On Mon, Apr 30, 2018 at 01:22:44PM -0700, Matthew Wilcox wrote:
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index e0e74e91f3e8..0e6117123737 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -134,7 +134,7 @@ struct page {
>  			unsigned long _pt_pad_1;	/* compound_head */
>  			pgtable_t pmd_huge_pte; /* protected by page->ptl */
>  			unsigned long _pt_pad_2;	/* mapping */
> -			unsigned long _pt_pad_3;
> +			struct mm_struct *pt_mm;

I guess it worth to have a comment that this field is only used of pgd
page tables and therefore doesn't conflict with pmd_huge_pte.

-- 
 Kirill A. Shutemov
