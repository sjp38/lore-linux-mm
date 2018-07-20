Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f197.google.com (mail-qk0-f197.google.com [209.85.220.197])
	by kanga.kvack.org (Postfix) with ESMTP id 7BF8D6B0003
	for <linux-mm@kvack.org>; Fri, 20 Jul 2018 15:16:07 -0400 (EDT)
Received: by mail-qk0-f197.google.com with SMTP id 123-v6so9981849qkg.8
        for <linux-mm@kvack.org>; Fri, 20 Jul 2018 12:16:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id j33-v6sor1376099qtc.87.2018.07.20.12.16.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 20 Jul 2018 12:16:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180626184422.24974-1-malat@debian.org>
References: <20180625171513.31845-1-malat@debian.org> <20180626184422.24974-1-malat@debian.org>
From: Tony Luck <tony.luck@gmail.com>
Date: Fri, 20 Jul 2018 12:16:05 -0700
Message-ID: <CA+8MBbLB5JTdcgS3yJRR12doMgEiofD8NNXedyYyj4c7AcDnMg@mail.gmail.com>
Subject: Re: [PATCH v3] mm/memblock: add missing include <linux/bootmem.h>
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mathieu Malaterre <malat@debian.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, Michal Hocko <mhocko@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Stefan Agner <stefan@agner.ch>, Joe Perches <joe@perches.com>, Andy Shevchenko <andriy.shevchenko@linux.intel.com>, linux-mm@kvack.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Tue, Jun 26, 2018 at 11:44 AM, Mathieu Malaterre <malat@debian.org> wrote:
> Because Makefile already does:
>
>   obj-$(CONFIG_HAVE_MEMBLOCK) += memblock.o
>
> The #ifdef has been simplified from:
>
>   #if defined(CONFIG_HAVE_MEMBLOCK) && defined(CONFIG_NO_BOOTMEM)
>
> to simply:
>
>   #if defined(CONFIG_NO_BOOTMEM)

Is this sitting in a queue somewhere ready to go to Linus?

I don't see it upstream yet.

>
> Suggested-by: Tony Luck <tony.luck@intel.com>
> Suggested-by: Michal Hocko <mhocko@kernel.org>
> Acked-by: Michal Hocko <mhocko@suse.com>
> Signed-off-by: Mathieu Malaterre <malat@debian.org>
> ---
> v3: Add missing reference to commit 6cc22dc08a24
> v2: Simplify #ifdef
>
>  mm/memblock.c | 3 +++
>  1 file changed, 3 insertions(+)
>
> diff --git a/mm/memblock.c b/mm/memblock.c
> index 03d48d8835ba..611a970ac902 100644
> --- a/mm/memblock.c
> +++ b/mm/memblock.c
> @@ -20,6 +20,7 @@
>  #include <linux/kmemleak.h>
>  #include <linux/seq_file.h>
>  #include <linux/memblock.h>
> +#include <linux/bootmem.h>
>
>  #include <asm/sections.h>
>  #include <linux/io.h>
> @@ -1224,6 +1225,7 @@ phys_addr_t __init memblock_alloc_try_nid(phys_addr_t size, phys_addr_t align, i
>         return memblock_alloc_base(size, align, MEMBLOCK_ALLOC_ACCESSIBLE);
>  }
>
> +#if defined(CONFIG_NO_BOOTMEM)
>  /**
>   * memblock_virt_alloc_internal - allocate boot memory block
>   * @size: size of memory block to be allocated in bytes
> @@ -1431,6 +1433,7 @@ void * __init memblock_virt_alloc_try_nid(
>               (u64)max_addr);
>         return NULL;
>  }
> +#endif
>
>  /**
>   * __memblock_free_early - free boot memory block
> --
> 2.11.0
>
