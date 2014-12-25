Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f44.google.com (mail-la0-f44.google.com [209.85.215.44])
	by kanga.kvack.org (Postfix) with ESMTP id C17536B0032
	for <linux-mm@kvack.org>; Thu, 25 Dec 2014 05:08:13 -0500 (EST)
Received: by mail-la0-f44.google.com with SMTP id gd6so7961141lab.17
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 02:08:12 -0800 (PST)
Received: from mail-la0-x22d.google.com (mail-la0-x22d.google.com. [2a00:1450:4010:c03::22d])
        by mx.google.com with ESMTPS id jq5si5591795lbc.39.2014.12.25.02.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 25 Dec 2014 02:08:12 -0800 (PST)
Received: by mail-la0-f45.google.com with SMTP id gq15so7958338lab.18
        for <linux-mm@kvack.org>; Thu, 25 Dec 2014 02:08:12 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1419423766-114457-25-git-send-email-kirill.shutemov@linux.intel.com>
References: <1419423766-114457-1-git-send-email-kirill.shutemov@linux.intel.com>
	<1419423766-114457-25-git-send-email-kirill.shutemov@linux.intel.com>
Date: Thu, 25 Dec 2014 11:08:11 +0100
Message-ID: <CAMuHMdWKNEeb3uOJ+gct06mbuD4RqP7F32FhMtax-tG7d_Yj1g@mail.gmail.com>
Subject: Re: [PATCH 24/38] mips: drop _PAGE_FILE and pte_file()-related helpers
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@kernel.org>, Dave Jones <davej@redhat.com>, Sasha Levin <sasha.levin@oracle.com>, Hugh Dickins <hughd@google.com>, Linux MM <linux-mm@kvack.org>, Linux-Arch <linux-arch@vger.kernel.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Ralf Baechle <ralf@linux-mips.org>

On Wed, Dec 24, 2014 at 1:22 PM, Kirill A. Shutemov
<kirill.shutemov@linux.intel.com> wrote:
> We've replaced remap_file_pages(2) implementation with emulation.
> Nobody creates non-linear mapping anymore.
>
> Signed-off-by: Kirill A. Shutemov <kirill.shutemov@linux.intel.com>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> ---
>  arch/m68k/include/asm/mcf_pgtable.h  |  6 ++----

This contains a change to an m68k header file.
The same file was modified in the m68k part of the series, but this change was
not included?

> --- a/arch/m68k/include/asm/mcf_pgtable.h
> +++ b/arch/m68k/include/asm/mcf_pgtable.h
> @@ -385,15 +385,13 @@ static inline void cache_page(void *vaddr)
>         *ptep = pte_mkcache(*ptep);
>  }
>
> -#define PTE_FILE_SHIFT         11
> -
>  /*
>   * Encode and de-code a swap entry (must be !pte_none(e) && !pte_present(e))
>   */
>  #define __swp_type(x)          ((x).val & 0xFF)
> -#define __swp_offset(x)                ((x).val >> PTE_FILE_SHIFT)
> +#define __swp_offset(x)                ((x).val >> 11)
>  #define __swp_entry(typ, off)  ((swp_entry_t) { (typ) | \
> -                                       (off << PTE_FILE_SHIFT) })
> +                                       (off << 11) })
>  #define __pte_to_swp_entry(pte)        ((swp_entry_t) { pte_val(pte) })
>  #define __swp_entry_to_pte(x)  (__pte((x).val))

Gr{oetje,eeting}s,

                        Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
