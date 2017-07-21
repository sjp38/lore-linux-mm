Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id A73366B0292
	for <linux-mm@kvack.org>; Fri, 21 Jul 2017 19:13:25 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 79so6592125wmg.4
        for <linux-mm@kvack.org>; Fri, 21 Jul 2017 16:13:25 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id t64si1720479wma.189.2017.07.21.16.13.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 21 Jul 2017 16:13:24 -0700 (PDT)
Date: Fri, 21 Jul 2017 16:13:22 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH] mm/gup: Make __gup_device_* require THP
Message-Id: <20170721161322.98c5cd44b5b3612be0f7fe14@linux-foundation.org>
In-Reply-To: <20170626063833.11094-1-oohall@gmail.com>
References: <20170626063833.11094-1-oohall@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: linux-mm@kvack.org, "Kirill A. Shutemov" <kirill@shutemov.name>

On Mon, 26 Jun 2017 16:38:33 +1000 "Oliver O'Halloran" <oohall@gmail.com> wrote:

> These functions are the only bits of generic code that use
> {pud,pmd}_pfn() without checking for CONFIG_TRANSPARENT_HUGEPAGE.
> This works fine on x86, the only arch with devmap support, since the
> *_pfn() functions are always defined there, but this isn't true for
> every architecture.
> 
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
>  mm/gup.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/mm/gup.c b/mm/gup.c
> index d9e6fddcc51f..04cf79291321 100644
> --- a/mm/gup.c
> +++ b/mm/gup.c
> @@ -1287,7 +1287,7 @@ static int gup_pte_range(pmd_t pmd, unsigned long addr, unsigned long end,
>  }
>  #endif /* __HAVE_ARCH_PTE_SPECIAL */
>  
> -#ifdef __HAVE_ARCH_PTE_DEVMAP
> +#if defined(__HAVE_ARCH_PTE_DEVMAP) && defined(CONFIG_TRANSPARENT_HUGEPAGE)
>  static int __gup_device_huge(unsigned long pfn, unsigned long addr,
>  		unsigned long end, struct page **pages, int *nr)
>  {

(cc Kirill)

Please provide a full description of the bug which is being fixed.  I
assume it's a build error.  What are the error messages and under what
circumstances.

Etcetera.  Enough info for me (and others) to decide which kernel
version(s) need the fix.

Thanks.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
