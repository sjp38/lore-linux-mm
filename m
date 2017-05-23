Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f198.google.com (mail-qt0-f198.google.com [209.85.216.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1756C6B0279
	for <linux-mm@kvack.org>; Tue, 23 May 2017 05:20:35 -0400 (EDT)
Received: by mail-qt0-f198.google.com with SMTP id a46so57835318qte.3
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:20:35 -0700 (PDT)
Received: from mail-qt0-x244.google.com (mail-qt0-x244.google.com. [2607:f8b0:400d:c0d::244])
        by mx.google.com with ESMTPS id r190si21185662qkb.125.2017.05.23.02.20.33
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 23 May 2017 02:20:34 -0700 (PDT)
Received: by mail-qt0-x244.google.com with SMTP id a46so21445744qte.0
        for <linux-mm@kvack.org>; Tue, 23 May 2017 02:20:33 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170523040524.13717-5-oohall@gmail.com>
References: <20170523040524.13717-1-oohall@gmail.com> <20170523040524.13717-5-oohall@gmail.com>
From: Balbir Singh <bsingharora@gmail.com>
Date: Tue, 23 May 2017 19:20:32 +1000
Message-ID: <CAKTCnznCuXpLFvGMRA9mGtTOdPbyEM3Xg0Z95-fC=9J_A3aEVw@mail.gmail.com>
Subject: Re: [PATCH 5/6] mm, x86: Add ARCH_HAS_ZONE_DEVICE
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oliver O'Halloran <oohall@gmail.com>
Cc: "open list:LINUX FOR POWERPC (32-BIT AND 64-BIT)" <linuxppc-dev@lists.ozlabs.org>, linux-mm <linux-mm@kvack.org>, "maintainer:X86 ARCHITECTURE (32-BIT AND 64-BIT)" <x86@kernel.org>

On Tue, May 23, 2017 at 2:05 PM, Oliver O'Halloran <oohall@gmail.com> wrote:
> Currently ZONE_DEVICE depends on X86_64. This is fine for now, but it
> will get unwieldly as new platforms get ZONE_DEVICE support. Moving it
> to an arch selected Kconfig option to save us some trouble in the
> future.
>
> Cc: x86@kernel.org
> Signed-off-by: Oliver O'Halloran <oohall@gmail.com>
> ---
>  arch/x86/Kconfig | 1 +
>  mm/Kconfig       | 5 ++++-
>  2 files changed, 5 insertions(+), 1 deletion(-)
>
> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
> index cd18994a9555..acbb15234562 100644
> --- a/arch/x86/Kconfig
> +++ b/arch/x86/Kconfig
> @@ -59,6 +59,7 @@ config X86
>         select ARCH_HAS_STRICT_KERNEL_RWX
>         select ARCH_HAS_STRICT_MODULE_RWX
>         select ARCH_HAS_UBSAN_SANITIZE_ALL
> +       select ARCH_HAS_ZONE_DEVICE             if X86_64
>         select ARCH_HAVE_NMI_SAFE_CMPXCHG
>         select ARCH_MIGHT_HAVE_ACPI_PDC         if ACPI
>         select ARCH_MIGHT_HAVE_PC_PARPORT
> diff --git a/mm/Kconfig b/mm/Kconfig
> index beb7a455915d..2d38a4abe957 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -683,12 +683,15 @@ config IDLE_PAGE_TRACKING
>
>           See Documentation/vm/idle_page_tracking.txt for more details.
>
> +config ARCH_HAS_ZONE_DEVICE
> +       def_bool n
> +
>  config ZONE_DEVICE
>         bool "Device memory (pmem, etc...) hotplug support"
>         depends on MEMORY_HOTPLUG
>         depends on MEMORY_HOTREMOVE
>         depends on SPARSEMEM_VMEMMAP
> -       depends on X86_64 #arch_add_memory() comprehends device memory
> +       depends on ARCH_HAS_ZONE_DEVICE
>
>         help
>           Device memory hotplug support allows for establishing pmem,

Acked-by: Balbir Singh <bsingharora@gmail.com>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
