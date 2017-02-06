Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 5E4EF6B0033
	for <linux-mm@kvack.org>; Mon,  6 Feb 2017 10:02:28 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id 204so109202996pge.5
        for <linux-mm@kvack.org>; Mon, 06 Feb 2017 07:02:28 -0800 (PST)
Received: from bombadil.infradead.org (bombadil.infradead.org. [65.50.211.133])
        by mx.google.com with ESMTPS id q75si896469pfi.281.2017.02.06.07.02.27
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 06 Feb 2017 07:02:27 -0800 (PST)
Date: Mon, 6 Feb 2017 07:02:24 -0800
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [PATCH v3 01/14] mm: thp: make __split_huge_pmd_locked visible.
Message-ID: <20170206150224.GJ2267@bombadil.infradead.org>
References: <20170205161252.85004-1-zi.yan@sent.com>
 <20170205161252.85004-2-zi.yan@sent.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20170205161252.85004-2-zi.yan@sent.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Zi Yan <zi.yan@sent.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kirill.shutemov@linux.intel.com, akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, mgorman@techsingularity.net, n-horiguchi@ah.jp.nec.com, khandual@linux.vnet.ibm.com, zi.yan@cs.rutgers.edu, Zi Yan <ziy@nvidia.com>

On Sun, Feb 05, 2017 at 11:12:39AM -0500, Zi Yan wrote:
> +++ b/include/linux/huge_mm.h
> @@ -120,6 +120,8 @@ static inline int split_huge_page(struct page *page)
>  }
>  void deferred_split_huge_page(struct page *page);
>  
> +void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long haddr, bool freeze);

Could you change that from 'haddr' to 'address' so callers who only
read the header instead of the implementation aren't expecting to align
it themselves?

> +void __split_huge_pmd_locked(struct vm_area_struct *vma, pmd_t *pmd,
> +		unsigned long address, bool freeze)
>  {
>  	struct mm_struct *mm = vma->vm_mm;
>  	struct page *page;

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
