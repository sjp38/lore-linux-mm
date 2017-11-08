Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f71.google.com (mail-it0-f71.google.com [209.85.214.71])
	by kanga.kvack.org (Postfix) with ESMTP id 5955544043C
	for <linux-mm@kvack.org>; Wed,  8 Nov 2017 14:52:14 -0500 (EST)
Received: by mail-it0-f71.google.com with SMTP id f187so6520375itb.6
        for <linux-mm@kvack.org>; Wed, 08 Nov 2017 11:52:14 -0800 (PST)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id e1sor2692908ith.134.2017.11.08.11.52.13
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 08 Nov 2017 11:52:13 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20171108194647.ABC9BC79@viggo.jf.intel.com>
References: <20171108194646.907A1942@viggo.jf.intel.com> <20171108194647.ABC9BC79@viggo.jf.intel.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Wed, 8 Nov 2017 11:52:12 -0800
Message-ID: <CA+55aFwuFT48RS=Bn9qvgjr+2r+jNroQHw1F+G_GxtU12nJmaw@mail.gmail.com>
Subject: Re: [PATCH 01/30] x86, mm: do not set _PAGE_USER for init_mm page tables
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, Thomas Gleixner <tglx@linutronix.de>, moritz.lipp@iaik.tugraz.at, Daniel Gruss <daniel.gruss@iaik.tugraz.at>, michael.schwarz@iaik.tugraz.at, richard.fellner@student.tugraz.at, Andrew Lutomirski <luto@kernel.org>, Kees Cook <keescook@google.com>, Hugh Dickins <hughd@google.com>, the arch/x86 maintainers <x86@kernel.org>

On Wed, Nov 8, 2017 at 11:46 AM, Dave Hansen
<dave.hansen@linux.intel.com> wrote:
>
> +
>  static inline void pmd_populate_kernel(struct mm_struct *mm,
>                                        pmd_t *pmd, pte_t *pte)
>  {
> +       pteval_t pgtable_flags = mm_pgtable_flags(mm);

Why is "pmd_populate_kernel()" using mm_pgtable_flags(mm)?

It should just use _KERNPG_TABLE unconditionally, shouldn't it?
Nothing to do with init_mm, it's populating a _kernel_ page table
regardless, no?

            Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
