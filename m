Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id A13CE6B025E
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 18:14:35 -0400 (EDT)
Received: by wibud3 with SMTP id ud3so145481813wib.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:14:35 -0700 (PDT)
Received: from mail-wi0-x22a.google.com (mail-wi0-x22a.google.com. [2a00:1450:400c:c05::22a])
        by mx.google.com with ESMTPS id cw6si43132901wjc.208.2015.07.21.15.14.33
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 15:14:34 -0700 (PDT)
Received: by wibud3 with SMTP id ud3so145481029wib.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 15:14:33 -0700 (PDT)
Date: Wed, 22 Jul 2015 01:14:29 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCHv2 0/6] Make vma_is_anonymous() reliable
Message-ID: <20150721221429.GA7478@node.dhcp.inet.fi>
References: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1437133993-91885-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Oleg Nesterov <oleg@redhat.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Fri, Jul 17, 2015 at 02:53:07PM +0300, Kirill A. Shutemov wrote:
> We rely on ->vm_ops == NULL to detect anonymous VMA but this check is not
> always reliable:
> 
>  - MPX sets ->vm_ops on anonymous VMA;
> 
>   - many drivers don't set ->vm_ops. See for instance hpet_mmap().
> 
>   This patchset makes vma_is_anonymous() more reliable and makes few
>   cleanups around the code.
> 
> v2:
>  - drop broken patch;
>  - more cleanup for mpx code (Oleg);
>  - vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd();
> 
> Kirill A. Shutemov (5):
>   mm: mark most vm_operations_struct const
>   x86, mpx: do not set ->vm_ops on mpx VMAs
>   mm: make sure all file VMAs have ->vm_ops set
>   mm: use vma_is_anonymous() in create_huge_pmd() and wp_huge_pmd()
>   mm, madvise: use vma_is_anonymous() to check for anon VMA
> 
> Oleg Nesterov (1):
>   mm, mpx: add "vm_flags_t vm_flags" arg to do_mmap_pgoff()

ping?

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
