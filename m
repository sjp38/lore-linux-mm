Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f200.google.com (mail-pl1-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 75DFF8E0001
	for <linux-mm@kvack.org>; Sat, 15 Sep 2018 05:21:09 -0400 (EDT)
Received: by mail-pl1-f200.google.com with SMTP id bh1-v6so5483217plb.15
        for <linux-mm@kvack.org>; Sat, 15 Sep 2018 02:21:09 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id q3-v6si9868142pgl.687.2018.09.15.02.21.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Sat, 15 Sep 2018 02:21:07 -0700 (PDT)
Date: Sat, 15 Sep 2018 02:21:01 -0700
From: Matthew Wilcox <willy@infradead.org>
Subject: Re: [RFC v10 PATCH 1/3] mm: mmap: zap pages with read mmap_sem in
 munmap
Message-ID: <20180915092101.GA31572@bombadil.infradead.org>
References: <1536957299-43536-1-git-send-email-yang.shi@linux.alibaba.com>
 <1536957299-43536-2-git-send-email-yang.shi@linux.alibaba.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536957299-43536-2-git-send-email-yang.shi@linux.alibaba.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yang Shi <yang.shi@linux.alibaba.com>
Cc: mhocko@kernel.org, ldufour@linux.vnet.ibm.com, vbabka@suse.cz, kirill@shutemov.name, akpm@linux-foundation.org, dave.hansen@intel.com, oleg@redhat.com, srikar@linux.vnet.ibm.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Sat, Sep 15, 2018 at 04:34:57AM +0800, Yang Shi wrote:
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Suggested-by: Kirill A. Shutemov <kirill@shutemov.name>
> Suggested-by: Matthew Wilcox <willy@infradead.org>

Reviewed-by: Matthew Wilcox <willy@infradead.org>

Looks good!  Thanks for sticking with this patch series.

Minor spelling fixes:

> -	/*
> -	 * Remove the vma's, and unmap the actual pages
> -	 */
> +	/* Detatch vmas from rbtree */

"Detach"

> +	/*
> +	 * mpx unmap need to be handled with write mmap_sem. It is safe to
> +	 * deal with it before unmap_region().
> +	 */

	 * mpx unmap needs to be called with mmap_sem held for write.
	 * It is safe to call it before unmap_region()

> +	ret = __do_munmap(mm, start, len, &uf, downgrade);
> +	/*
> +	 * Returning 1 indicates mmap_sem is down graded.
> +	 * But 1 is not legal return value of vm_munmap() and munmap(), reset
> +	 * it to 0 before return.
> +	 */

"downgraded" is one word.
