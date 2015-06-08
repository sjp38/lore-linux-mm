Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f177.google.com (mail-wi0-f177.google.com [209.85.212.177])
	by kanga.kvack.org (Postfix) with ESMTP id E703E6B0032
	for <linux-mm@kvack.org>; Mon,  8 Jun 2015 07:52:26 -0400 (EDT)
Received: by wiga1 with SMTP id a1so83492640wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 04:52:26 -0700 (PDT)
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com. [209.85.212.181])
        by mx.google.com with ESMTPS id ey9si738609wid.37.2015.06.08.04.52.24
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 08 Jun 2015 04:52:24 -0700 (PDT)
Received: by wiga1 with SMTP id a1so83491688wig.0
        for <linux-mm@kvack.org>; Mon, 08 Jun 2015 04:52:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55704B0C.1000308@huawei.com>
References: <55704A7E.5030507@huawei.com> <55704B0C.1000308@huawei.com>
From: Leon Romanovsky <leon@leon.nu>
Date: Mon, 8 Jun 2015 14:52:03 +0300
Message-ID: <CALq1K=J7BuqMDkPrjioRVyRedHLhmM-gg8MOb9GSBcrmNah23g@mail.gmail.com>
Subject: Re: [RFC PATCH 01/12] mm: add a new config to manage the code
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Xishi Qiu <qiuxishi@huawei.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, nao.horiguchi@gmail.com, Yinghai Lu <yinghai@kernel.org>, "H. Peter Anvin" <hpa@zytor.com>, Thomas Gleixner <tglx@linutronix.de>, mingo@elte.hu, Xiexiuqi <xiexiuqi@huawei.com>, Hanjun Guo <guohanjun@huawei.com>, "Luck, Tony" <tony.luck@intel.com>, Linux MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>

On Thu, Jun 4, 2015 at 3:56 PM, Xishi Qiu <qiuxishi@huawei.com> wrote:
> This patch introduces a new config called "CONFIG_ACPI_MIRROR_MEMORY", it is
> used to on/off the feature.
>
> Signed-off-by: Xishi Qiu <qiuxishi@huawei.com>
> ---
>  mm/Kconfig | 8 ++++++++
>  1 file changed, 8 insertions(+)
>
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 390214d..4f2a726 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -200,6 +200,14 @@ config MEMORY_HOTREMOVE
>         depends on MEMORY_HOTPLUG && ARCH_ENABLE_MEMORY_HOTREMOVE
>         depends on MIGRATION
>
> +config MEMORY_MIRROR
> +       bool "Address range mirroring support"
> +       depends on X86 && NUMA
> +       default y
Is it correct for the systems (NOT xeon) without memory support built in?

> +       help
> +         This feature depends on hardware and firmware support.
> +         ACPI or EFI records the mirror info.
> +
>  #
>  # If we have space for more page flags then we can enable additional
>  # optimizations and functionality.
> --
> 2.0.0
>
>
> --
> To unsubscribe, send a message with 'unsubscribe linux-mm' in
> the body to majordomo@kvack.org.  For more info on Linux MM,
> see: http://www.linux-mm.org/ .
> Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>



-- 
Leon Romanovsky | Independent Linux Consultant
        www.leon.nu | leon@leon.nu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
