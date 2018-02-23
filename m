Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 7B5186B0003
	for <linux-mm@kvack.org>; Fri, 23 Feb 2018 03:01:05 -0500 (EST)
Received: by mail-wm0-f69.google.com with SMTP id e74so899405wmg.0
        for <linux-mm@kvack.org>; Fri, 23 Feb 2018 00:01:05 -0800 (PST)
Received: from pegase1.c-s.fr (pegase1.c-s.fr. [93.17.236.30])
        by mx.google.com with ESMTPS id z30si714524wrc.139.2018.02.23.00.01.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Feb 2018 00:01:04 -0800 (PST)
Subject: Re: [PATCH 0/5] PPC32/ioremap: Use memblock API to check for RAM
References: <20180222121516.23415-1-j.neuschaefer@gmx.net>
From: Christophe LEROY <christophe.leroy@c-s.fr>
Message-ID: <ca471c17-d2a7-e8e6-2d5a-a5a534e7e6d9@c-s.fr>
Date: Fri, 23 Feb 2018 09:01:17 +0100
MIME-Version: 1.0
In-Reply-To: <20180222121516.23415-1-j.neuschaefer@gmx.net>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: fr
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: =?UTF-8?Q?Jonathan_Neusch=c3=a4fer?= <j.neuschaefer@gmx.net>, linuxppc-dev@lists.ozlabs.org
Cc: linux-kernel@vger.kernel.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Joel Stanley <joel@jms.id.au>



Le 22/02/2018 A  13:15, Jonathan NeuschA?fer a A(C)critA :
> This patchset solves the same problem as my previous one[1] but follows
> a rather different approach. Instead of implementing DISCONTIGMEM for
> PowerPC32, I simply switched the "is this RAM" check in __ioremap_caller
> to the existing page_is_ram function, and unified page_is_ram to search
> memblock.memory on PPC64 and PPC32.
> 
> The intended result is, as before, that my Wii can allocate the MMIO
> range of its GPIO controller, which was previously not possible, because
> the reserved memory hack (__allow_ioremap_reserved) didn't affect the
> API in kernel/resource.c.
> 
> Thanks to Christophe Leroy for reviewing the previous patchset.

I tested your new serie, it doesn't break my 8xx so it is OK for me.

Christophe

> 
> [1]: https://www.spinics.net/lists/kernel/msg2726786.html
> 
> Jonathan NeuschA?fer (5):
>    powerpc: mm: Simplify page_is_ram by using memblock_is_memory
>    powerpc: mm: Use memblock API for PPC32 page_is_ram
>    powerpc/mm/32: Use page_is_ram to check for RAM
>    powerpc: wii: Don't rely on the reserved memory hack
>    powerpc/mm/32: Remove the reserved memory hack
> 
>   arch/powerpc/mm/init_32.c                |  5 -----
>   arch/powerpc/mm/mem.c                    | 12 +-----------
>   arch/powerpc/mm/mmu_decl.h               |  1 -
>   arch/powerpc/mm/pgtable_32.c             |  4 +---
>   arch/powerpc/platforms/embedded6xx/wii.c | 14 +-------------
>   5 files changed, 3 insertions(+), 33 deletions(-)
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
