Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wj0-f197.google.com (mail-wj0-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id 0B0BB6B0069
	for <linux-mm@kvack.org>; Mon, 12 Dec 2016 16:02:13 -0500 (EST)
Received: by mail-wj0-f197.google.com with SMTP id hb5so29255198wjc.2
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:02:12 -0800 (PST)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id s10si46360597wjo.159.2016.12.12.13.02.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 12 Dec 2016 13:02:11 -0800 (PST)
Received: by mail-wm0-x242.google.com with SMTP id g23so13879387wme.1
        for <linux-mm@kvack.org>; Mon, 12 Dec 2016 13:02:11 -0800 (PST)
Date: Tue, 13 Dec 2016 00:02:09 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 2/2] mm/thp/pagecache/collapse: Free the pte page table
 on collapse for thp page cache.
Message-ID: <20161212210209.GC10202@node.shutemov.name>
References: <20161212163428.6780-1-aneesh.kumar@linux.vnet.ibm.com>
 <20161212163428.6780-2-aneesh.kumar@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20161212163428.6780-2-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Cc: akpm@linux-foundation.org, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, mpe@ellerman.id.au, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Mon, Dec 12, 2016 at 10:04:28PM +0530, Aneesh Kumar K.V wrote:
> With THP page cache, when trying to build a huge page from regular pte pages,
> we just clear the pmd entry. We will take another fault and at that point we
> will find the huge page in the radix tree, thereby using the huge page to
> complete the page fault
> 
> The second fault path will allocate the needed pgtable_t page for archs like
> ppc64. So no need to deposit the same in collapse path. Depositing them in
> the collapse path resulting in a pgtable_t memory leak also giving errors like
> "[ 2362.021762] BUG: non-zero nr_ptes on freeing mm: 3"
> 
> Fixes:"mm: THP page cache support for ppc64"
> 
> Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
