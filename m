Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id E1A436B0006
	for <linux-mm@kvack.org>; Thu, 10 May 2018 03:45:58 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id e64-v6so935082vkd.5
        for <linux-mm@kvack.org>; Thu, 10 May 2018 00:45:58 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j3-v6sor82412uaj.135.2018.05.10.00.45.57
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 10 May 2018 00:45:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180510014447.15989-3-mcgrof@kernel.org>
References: <20180510014447.15989-1-mcgrof@kernel.org> <20180510014447.15989-3-mcgrof@kernel.org>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Thu, 10 May 2018 09:45:56 +0200
Message-ID: <CAMuHMdUJTKqqWzFi594_y_F1HdONr3+FOSTzg-n0ogoroFUqpA@mail.gmail.com>
Subject: Re: [PATCH v2 2/2] mm: provide a fallback for PAGE_KERNEL_EXEC for architectures
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Luis R. Rodriguez" <mcgrof@kernel.org>
Cc: Arnd Bergmann <arnd@arndb.de>, Greg KH <gregkh@linuxfoundation.org>, Matthew Wilcox <willy@infradead.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux-Arch <linux-arch@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Luis,

On Thu, May 10, 2018 at 3:44 AM, Luis R. Rodriguez <mcgrof@kernel.org> wrote:
> Some architectures just don't have PAGE_KERNEL_EXEC. The mm/nommu.c
> and mm/vmalloc.c code have been using PAGE_KERNEL as a fallback for years.
> Move this fallback to asm-generic.
>
> Architectures which do not define PAGE_KERNEL_EXEC yet:
>
>   o alpha
>   o mips
>   o openrisc
>   o sparc64

The above list seems to be far from complete?

> Suggested-by: Matthew Wilcox <willy@infradead.org>
> Signed-off-by: Luis R. Rodriguez <mcgrof@kernel.org>

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
