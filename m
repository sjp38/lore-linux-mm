Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id D3F4A8E0001
	for <linux-mm@kvack.org>; Fri, 14 Sep 2018 15:53:09 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id t9-v6so8307915qkl.2
        for <linux-mm@kvack.org>; Fri, 14 Sep 2018 12:53:09 -0700 (PDT)
Received: from NAM05-BY2-obe.outbound.protection.outlook.com (mail-by2nam05on0714.outbound.protection.outlook.com. [2a01:111:f400:fe52::714])
        by mx.google.com with ESMTPS id q26-v6si88805qtl.339.2018.09.14.12.53.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 14 Sep 2018 12:53:08 -0700 (PDT)
Date: Fri, 14 Sep 2018 12:53:00 -0700
From: Paul Burton <paul.burton@mips.com>
Subject: Re: [PATCH v2] mips: switch to NO_BOOTMEM
Message-ID: <20180914195300.7wnmsph2qhpixm7s@pburton-laptop>
References: <1536571398-29194-1-git-send-email-rppt@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1536571398-29194-1-git-send-email-rppt@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mike Rapoport <rppt@linux.vnet.ibm.com>
Cc: Serge Semin <fancer.lancer@gmail.com>, Ralf Baechle <ralf@linux-mips.org>, James Hogan <jhogan@kernel.org>, Huacai Chen <chenhc@lemote.com>, Michal Hocko <mhocko@kernel.org>, linux-mips@linux-mips.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Hi Mike,

On Mon, Sep 10, 2018 at 12:23:18PM +0300, Mike Rapoport wrote:
> MIPS already has memblock support and all the memory is already registered
> with it.
> 
> This patch replaces bootmem memory reservations with memblock ones and
> removes the bootmem initialization.
> 
> Since memblock allocates memory in top-down mode, we ensure that memblock
> limit is max_low_pfn to prevent allocations from the high memory.
> 
> To have the exceptions base in the lower 512M of the physical memory, its
> allocation in arch/mips/kernel/traps.c::traps_init() is using bottom-up
> mode.
> 
> Signed-off-by: Mike Rapoport <rppt@linux.vnet.ibm.com>
> ---
> v2:
> * set memblock limit to max_low_pfn to avoid allocation attempts from high
> memory
> * use boottom-up mode for allocation of the exceptions base
> 
> Build tested with *_defconfig.
> Boot tested with qemu-system-mips64el for 32r6el, 64r6el and fuloong2e
> defconfigs.
> Boot tested with qemu-system-mipsel for malta defconfig.
> 
>  arch/mips/Kconfig                      |  1 +
>  arch/mips/kernel/setup.c               | 99 ++++++++--------------------------
>  arch/mips/kernel/traps.c               |  3 ++
>  arch/mips/loongson64/loongson-3/numa.c | 34 ++++++------
>  arch/mips/sgi-ip27/ip27-memory.c       | 11 ++--
>  5 files changed, 46 insertions(+), 102 deletions(-)

Thanks - applied to mips-next for 4.20.

Apologies for the delay, my son decided to be born a few weeks early &
scupper my plans :)

Paul
