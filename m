Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f69.google.com (mail-vk0-f69.google.com [209.85.213.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7725A6B026B
	for <linux-mm@kvack.org>; Wed,  4 Jul 2018 09:05:21 -0400 (EDT)
Received: by mail-vk0-f69.google.com with SMTP id h81-v6so310836vke.13
        for <linux-mm@kvack.org>; Wed, 04 Jul 2018 06:05:21 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 124-v6sor1324299vkc.222.2018.07.04.06.05.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 04 Jul 2018 06:05:20 -0700 (PDT)
MIME-Version: 1.0
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
 <1530685696-14672-4-git-send-email-rppt@linux.vnet.ibm.com>
 <CAMuHMdWEHSz34bN-U3gHW972w13f_Jrx_ObEsP3w8XZ1Gx65OA@mail.gmail.com>
 <20180704075410.GF22503@dhcp22.suse.cz> <89f48f7a-6cbf-ac9a-cacc-cd3ca79f8c66@suse.cz>
 <20180704123627.GM22503@dhcp22.suse.cz>
In-Reply-To: <20180704123627.GM22503@dhcp22.suse.cz>
From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Wed, 4 Jul 2018 15:05:08 +0200
Message-ID: <CAMuHMdVuLd=y4Wk6ghFZ8YV_1Z9kvh588VkwBMwxScxateMu1g@mail.gmail.com>
Subject: Re: [PATCH v2 3/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Vlastimil Babka <vbabka@suse.cz>, Mike Rapoport <rppt@linux.vnet.ibm.com>, Greg Ungerer <gerg@linux-m68k.org>, Sam Creasey <sammy@sammy.net>, linux-m68k <linux-m68k@lists.linux-m68k.org>, Linux MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

Hi Michal,

On Wed, Jul 4, 2018 at 2:36 PM Michal Hocko <mhocko@kernel.org> wrote:
> [CC Andrew - email thread starts
> http://lkml.kernel.org/r/1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com]
>
> OK, so here we go with the full patch.
>
> From 0e8432b875d98a7a0d3f757fce2caa8d16a8de15 Mon Sep 17 00:00:00 2001
> From: Michal Hocko <mhocko@suse.com>
> Date: Wed, 4 Jul 2018 14:31:46 +0200
> Subject: [PATCH] memblock: do not complain about top-down allocations for
>  !MEMORY_HOTREMOVE
>
> Mike Rapoport is converting architectures from bootmem to noboodmem

nobootmem

> allocator. While doing so for m68k Geert has noticed that he gets
> a scary looking warning
> WARNING: CPU: 0 PID: 0 at mm/memblock.c:230
> memblock_find_in_range_node+0x11c/0x1be
> memblock: bottom-up allocation failed, memory hotunplug may be affected

> The warning is basically saying that a top-down allocation can break
> memory hotremove because memblock allocation is not movable. But m68k
> doesn't even support MEMORY_HOTREMOVE is there is no point to warn

so there is

> about it.
>
> Make the warning conditional only to configurations that care.

Still, I'm wondering if the warning is really that unlikely on systems
that support
hotremove. Or is it due to the low amount of RAM on m68k boxes?

Gr{oetje,eeting}s,

                        Geert

-- 
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
                                -- Linus Torvalds
