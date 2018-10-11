Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f198.google.com (mail-pg1-f198.google.com [209.85.215.198])
	by kanga.kvack.org (Postfix) with ESMTP id E71B16B0008
	for <linux-mm@kvack.org>; Thu, 11 Oct 2018 01:14:26 -0400 (EDT)
Received: by mail-pg1-f198.google.com with SMTP id i189-v6so5236807pge.6
        for <linux-mm@kvack.org>; Wed, 10 Oct 2018 22:14:26 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i3-v6sor13359994pfj.39.2018.10.10.22.14.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 10 Oct 2018 22:14:25 -0700 (PDT)
Date: Thu, 11 Oct 2018 08:14:19 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: [PATCH] mm: Speed up mremap on large regions
Message-ID: <20181011051419.2rkfbooqc3auk5ji@kshutemo-mobl1>
References: <20181009201400.168705-1-joel@joelfernandes.org>
 <20181009220222.26nzajhpsbt7syvv@kshutemo-mobl1>
 <20181009230447.GA17911@joelaf.mtv.corp.google.com>
 <20181010100011.6jqjvgeslrvvyhr3@kshutemo-mobl1>
 <20181011004618.GA237677@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181011004618.GA237677@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@android.com, minchan@google.com, hughd@google.com, lokeshgidra@google.com, Andrew Morton <akpm@linux-foundation.org>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Thomas Gleixner <tglx@linutronix.de>

On Wed, Oct 10, 2018 at 05:46:18PM -0700, Joel Fernandes wrote:
> diff --git a/arch/powerpc/include/asm/book3s/64/pgalloc.h b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> index 391ed2c3b697..8a33f2044923 100644
> --- a/arch/powerpc/include/asm/book3s/64/pgalloc.h
> +++ b/arch/powerpc/include/asm/book3s/64/pgalloc.h
> @@ -192,14 +192,12 @@ static inline pgtable_t pmd_pgtable(pmd_t pmd)
>  	return (pgtable_t)pmd_page_vaddr(pmd);
>  }
>  
> -static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm,
> -					  unsigned long address)
> +static inline pte_t *pte_alloc_one_kernel(struct mm_struct *mm)
>  {
>  	return (pte_t *)pte_fragment_alloc(mm, address, 1);
>  }

This is obviously broken.

-- 
 Kirill A. Shutemov
