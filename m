Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AE4156B000A
	for <linux-mm@kvack.org>; Mon,  6 Aug 2018 05:04:44 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id j15-v6so8209106pff.12
        for <linux-mm@kvack.org>; Mon, 06 Aug 2018 02:04:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 34-v6sor2922833plm.89.2018.08.06.02.04.43
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 06 Aug 2018 02:04:43 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180804220827.GA12559@embeddedor.com>
References: <20180804220827.GA12559@embeddedor.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Mon, 6 Aug 2018 11:04:22 +0200
Message-ID: <CACT4Y+arVJ4qt54LzKKoyh9+NKA+fjyCShKi82NanbovhK_mmQ@mail.gmail.com>
Subject: Re: [PATCH] mm/kasan/kasan_init: use true and false for boolean values
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Gustavo A. R. Silva" <gustavo@embeddedor.com>
Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>, Alexander Potapenko <glider@google.com>, kasan-dev <kasan-dev@googlegroups.com>, Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Sun, Aug 5, 2018 at 12:08 AM, Gustavo A. R. Silva
<gustavo@embeddedor.com> wrote:
> Return statements in functions returning bool should use true or false
> instead of an integer value.
>
> This code was detected with the help of Coccinelle.
>
> Signed-off-by: Gustavo A. R. Silva <gustavo@embeddedor.com>

Hi Gustavo,

I don't see this code in upstream tree. Is it against some other tree? Which?

Thanks

> ---
>  mm/kasan/kasan_init.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
>
> diff --git a/mm/kasan/kasan_init.c b/mm/kasan/kasan_init.c
> index 7a2a2f1..c742dc5 100644
> --- a/mm/kasan/kasan_init.c
> +++ b/mm/kasan/kasan_init.c
> @@ -42,7 +42,7 @@ static inline bool kasan_p4d_table(pgd_t pgd)
>  #else
>  static inline bool kasan_p4d_table(pgd_t pgd)
>  {
> -       return 0;
> +       return false;
>  }
>  #endif
>  #if CONFIG_PGTABLE_LEVELS > 3
> @@ -54,7 +54,7 @@ static inline bool kasan_pud_table(p4d_t p4d)
>  #else
>  static inline bool kasan_pud_table(p4d_t p4d)
>  {
> -       return 0;
> +       return false;
>  }
>  #endif
>  #if CONFIG_PGTABLE_LEVELS > 2
> @@ -66,7 +66,7 @@ static inline bool kasan_pmd_table(pud_t pud)
>  #else
>  static inline bool kasan_pmd_table(pud_t pud)
>  {
> -       return 0;
> +       return false;
>  }
>  #endif
>  pte_t kasan_zero_pte[PTRS_PER_PTE] __page_aligned_bss;
> --
> 2.7.4
