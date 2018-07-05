Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id CC56B6B0005
	for <linux-mm@kvack.org>; Thu,  5 Jul 2018 08:14:00 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id b65-v6so1985434plb.5
        for <linux-mm@kvack.org>; Thu, 05 Jul 2018 05:14:00 -0700 (PDT)
Received: from icp-osb-irony-out7.external.iinet.net.au (icp-osb-irony-out7.external.iinet.net.au. [203.59.1.107])
        by mx.google.com with ESMTP id m37-v6si6108934pla.148.2018.07.05.05.13.56
        for <linux-mm@kvack.org>;
        Thu, 05 Jul 2018 05:13:57 -0700 (PDT)
Subject: Re: [PATCH v2 0/3] m68k: switch to MEMBLOCK + NO_BOOTMEM
References: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
From: Greg Ungerer <gerg@linux-m68k.org>
Message-ID: <4c08ad85-95f8-7001-5429-eaaf36d061de@linux-m68k.org>
Date: Thu, 5 Jul 2018 22:13:52 +1000
MIME-Version: 1.0
In-Reply-To: <1530685696-14672-1-git-send-email-rppt@linux.vnet.ibm.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>, Geert Uytterhoeven <geert@linux-m68k.org>, Sam Creasey <sammy@sammy.net>
Cc: Michal Hocko <mhocko@kernel.org>, linux-m68k@lists.linux-m68k.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike,

On 04/07/18 16:28, Mike Rapoport wrote:
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

I am happy with all of these, so for me:

Acked-by: Greg Ungerer <gerg@linux-m68k.org>

Regards
Greg



> Mike Rapoport (3):
>    m68k/bitops: convert __ffs to match generic declaration
>    m68k/page_no.h: force __va argument to be unsigned long
>    m68k: switch to MEMBLOCK + NO_BOOTMEM
> 
>   arch/m68k/Kconfig               |  3 +++
>   arch/m68k/include/asm/bitops.h  |  8 ++++++--
>   arch/m68k/include/asm/page_no.h |  2 +-
>   arch/m68k/kernel/setup_mm.c     | 14 ++++----------
>   arch/m68k/kernel/setup_no.c     | 20 ++++----------------
>   arch/m68k/mm/init.c             |  1 -
>   arch/m68k/mm/mcfmmu.c           | 13 +++++++------
>   arch/m68k/mm/motorola.c         | 35 +++++++++++------------------------
>   arch/m68k/sun3/config.c         |  4 ----
>   9 files changed, 36 insertions(+), 64 deletions(-)
> 
