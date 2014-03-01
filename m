Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id E82B06B0055
	for <linux-mm@kvack.org>; Sat,  1 Mar 2014 12:38:28 -0500 (EST)
Received: by mail-pd0-f176.google.com with SMTP id r10so2052732pdi.35
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 09:38:28 -0800 (PST)
Received: from mail-pd0-x233.google.com (mail-pd0-x233.google.com [2607:f8b0:400e:c02::233])
        by mx.google.com with ESMTPS id zo6si5917080pbc.133.2014.03.01.09.38.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sat, 01 Mar 2014 09:38:28 -0800 (PST)
Received: by mail-pd0-f179.google.com with SMTP id w10so2037159pde.24
        for <linux-mm@kvack.org>; Sat, 01 Mar 2014 09:38:27 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1393689748-32236-2-git-send-email-gidisrael@gmail.com>
References: <1393689748-32236-1-git-send-email-gidisrael@gmail.com>
	<1393689748-32236-2-git-send-email-gidisrael@gmail.com>
Date: Sat, 1 Mar 2014 18:38:27 +0100
Message-ID: <CAMuHMdUiE5QxZZxx-U0W6G=mwGjS8deemMZy_ib5FYmnx6VD+w@mail.gmail.com>
Subject: Re: [PATCH 1/1] mm: use macros from compiler.h instead of __attribute__((...))
From: Geert Uytterhoeven <geert@linux-m68k.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Gideon Israel Dsouza <gidisrael@gmail.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Linux MM <linux-mm@kvack.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>

On Sat, Mar 1, 2014 at 5:02 PM, Gideon Israel Dsouza
<gidisrael@gmail.com> wrote:
> --- a/mm/sparse.c
> +++ b/mm/sparse.c
> @@ -9,6 +9,8 @@
>  #include <linux/export.h>
>  #include <linux/spinlock.h>
>  #include <linux/vmalloc.h>
> +#include <linux/compiler.h>

Please try to insert new includes in alphabetical order, to avoid
merge conflicts.
It's no always easy, as lots of include lists are not sorted at all.

> +
>  #include "internal.h"
>  #include <asm/dma.h>
>  #include <asm/pgalloc.h>
> @@ -459,9 +461,9 @@ static struct page __init *sparse_early_mem_map_alloc(unsigned long pnum)
>         ms->section_mem_map = 0;
>         return NULL;
>  }
> -#endif
> +endif

Woops, this won't compile?

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
