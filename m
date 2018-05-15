Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 738456B0006
	for <linux-mm@kvack.org>; Tue, 15 May 2018 05:27:28 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id e1-v6so4804916wma.3
        for <linux-mm@kvack.org>; Tue, 15 May 2018 02:27:28 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id w50-v6si2265489edm.249.2018.05.15.02.27.27
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 15 May 2018 02:27:27 -0700 (PDT)
Subject: Re: [PATCH v5 12/17] mm: Add pt_mm to struct page
References: <20180504183318.14415-1-willy@infradead.org>
 <20180504183318.14415-13-willy@infradead.org>
From: Vlastimil Babka <vbabka@suse.cz>
Message-ID: <89ea9412-22fe-d08c-718c-15bc816ec47c@suse.cz>
Date: Tue, 15 May 2018 11:27:25 +0200
MIME-Version: 1.0
In-Reply-To: <20180504183318.14415-13-willy@infradead.org>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>, linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, Andrew Morton <akpm@linux-foundation.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Christoph Lameter <cl@linux.com>, Lai Jiangshan <jiangshanlai@gmail.com>, Pekka Enberg <penberg@kernel.org>, Dave Hansen <dave.hansen@linux.intel.com>, =?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>

On 05/04/2018 08:33 PM, Matthew Wilcox wrote:
> From: Matthew Wilcox <mawilcox@microsoft.com>
> 
> x86 overloads the page->index field to store a pointer to the mm_struct.

Maybe start the sentence with "For page table pages, ..." or "For pgd
page table pages, ..." ?

> Rename this to pt_mm so it's visible to other users.
> 
> Signed-off-by: Matthew Wilcox <mawilcox@microsoft.com>

Also a suggestion below, otherwise:

Acked-by: Vlastimil Babka <vbabka@suse.cz>

>  static void pgd_ctor(struct mm_struct *mm, pgd_t *pgd)
> diff --git a/include/linux/mm_types.h b/include/linux/mm_types.h
> index 90a6dbeeef11..5a519279dcd5 100644
> --- a/include/linux/mm_types.h
> +++ b/include/linux/mm_types.h
> @@ -139,7 +139,7 @@ struct page {
>  			unsigned long _pt_pad_1;	/* compound_head */
>  			pgtable_t pmd_huge_pte; /* protected by page->ptl */
>  			unsigned long _pt_pad_2;	/* mapping */
> -			unsigned long _pt_pad_3;
> +			struct mm_struct *pt_mm;

Add comment that it's x86-only so somebody doesn't try to write a
generic code expecting it?

>  #if ALLOC_SPLIT_PTLOCKS
>  			spinlock_t *ptl;
>  #else
> 
