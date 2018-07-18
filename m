Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 1D1CF6B0006
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 07:39:33 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id v129-v6so1547869vke.16
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 04:39:33 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124-v6sor1350773vkm.51.2018.07.18.04.39.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 04:39:32 -0700 (PDT)
MIME-Version: 1.0
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
In-Reply-To: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 18 Jul 2018 13:39:19 +0200
Message-ID: <CAMuHMdWOCtrYN4t4y5eucy1juE3L8fkb1PaZ9gJ9a=jMXV+FGQ@mail.gmail.com>
Subject: Re: [PATCH v2 0/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, Michal Hocko <mhocko@kernel.org>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Mike,

On Wed, Jul 4, 2018 at 8:28 AM Mike Rapoport <rppt@linux.vnet.ibm.com> wrote:
> These patches switch m68k boot time memory allocators from bootmem to
> memblock + no_bootmem.
>
> The first two patches update __ffs() and __va() definitions to be inline
> with other arches and asm-generic. This is required to avoid compilation
> warnings in mm/memblock.c and mm/nobootmem.c.
>
> The third patch performs the actual switch of the boot time mm. Its
> changelog has detailed description of the changes.
>
> I've tested the !MMU version with qemu-system-m68k -M mcf5208evb
> and the MMU version with q800 using qemu from [1].
>
> I've also build tested allyesconfig and *_defconfig.
>
> [1] https://github.com/vivier/qemu-m68k.git
>
> v2:
> * fix reservation of the kernel text/data/bss for ColdFire MMU

Boots fine on the real Amiga, too. Let's assume it works on Sun 3 too.
Thanks a lot, applied and queued for v4.19.

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
