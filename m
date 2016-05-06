Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f72.google.com (mail-lf0-f72.google.com [209.85.215.72])
	by kanga.kvack.org (Postfix) with ESMTP id A14706B0260
	for <linux-mm@kvack.org>; Fri,  6 May 2016 13:33:50 -0400 (EDT)
Received: by mail-lf0-f72.google.com with SMTP id y84so42361868lfc.3
        for <linux-mm@kvack.org>; Fri, 06 May 2016 10:33:50 -0700 (PDT)
Received: from mail-lf0-x232.google.com (mail-lf0-x232.google.com. [2a00:1450:4010:c07::232])
        by mx.google.com with ESMTPS id l201si11662358lfb.209.2016.05.06.10.33.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 10:33:49 -0700 (PDT)
Received: by mail-lf0-x232.google.com with SMTP id m64so138996104lfd.1
        for <linux-mm@kvack.org>; Fri, 06 May 2016 10:33:49 -0700 (PDT)
Date: Fri, 6 May 2016 20:33:47 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH 3/3] mm: thp: split_huge_pmd_address() comment improvement
Message-ID: <20160506173347.GB9879@node.shutemov.name>
References: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
 <1462547040-1737-4-git-send-email-aarcange@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1462547040-1737-4-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, Alex Williamson <alex.williamson@redhat.com>

On Fri, May 06, 2016 at 05:04:00PM +0200, Andrea Arcangeli wrote:
> Comment is partly wrong, this improves it by including the case of
> split_huge_pmd_address() called by try_to_unmap_one if
> TTU_SPLIT_HUGE_PMD is set.
> 
> Signed-off-by: Andrea Arcangeli <aarcange@redhat.com>

Acked-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>

> ---
>  mm/huge_memory.c | 6 ++++--
>  1 file changed, 4 insertions(+), 2 deletions(-)
> 
> diff --git a/mm/huge_memory.c b/mm/huge_memory.c
> index 9086793..1fbe13d 100644
> --- a/mm/huge_memory.c
> +++ b/mm/huge_memory.c
> @@ -3031,8 +3031,10 @@ void split_huge_pmd_address(struct vm_area_struct *vma, unsigned long address,
>  		return;
>  
>  	/*
> -	 * Caller holds the mmap_sem write mode, so a huge pmd cannot
> -	 * materialize from under us.
> +	 * Caller holds the mmap_sem write mode or the anon_vma lock,
> +	 * so a huge pmd cannot materialize from under us (khugepaged
> +	 * holds both the mmap_sem write mode and the anon_vma lock
> +	 * write mode).
>  	 */
>  	__split_huge_pmd(vma, pmd, address, freeze);
>  }

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
