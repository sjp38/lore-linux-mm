Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f70.google.com (mail-it0-f70.google.com [209.85.214.70])
	by kanga.kvack.org (Postfix) with ESMTP id DFF2A6B0005
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 14:08:50 -0400 (EDT)
Received: by mail-it0-f70.google.com with SMTP id 7-v6so2494269itv.5
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:08:50 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id v8-v6si6697522jag.85.2018.06.29.11.08.49
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 29 Jun 2018 11:08:49 -0700 (PDT)
Received: from pps.filterd (userp2130.oracle.com [127.0.0.1])
	by userp2130.oracle.com (8.16.0.22/8.16.0.22) with SMTP id w5TI8n4b076372
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:08:49 GMT
Received: from userv0021.oracle.com (userv0021.oracle.com [156.151.31.71])
	by userp2130.oracle.com with ESMTP id 2jum587f4m-1
	(version=TLSv1.2 cipher=ECDHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:08:48 +0000
Received: from aserv0121.oracle.com (aserv0121.oracle.com [141.146.126.235])
	by userv0021.oracle.com (8.14.4/8.14.4) with ESMTP id w5TI8iJk006510
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-GCM-SHA384 bits=256 verify=OK)
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:08:44 GMT
Received: from abhmp0004.oracle.com (abhmp0004.oracle.com [141.146.116.10])
	by aserv0121.oracle.com (8.14.4/8.13.8) with ESMTP id w5TI8ioB009655
	for <linux-mm@kvack.org>; Fri, 29 Jun 2018 18:08:44 GMT
Received: by mail-oi0-f53.google.com with SMTP id n84-v6so9228663oib.9
        for <linux-mm@kvack.org>; Fri, 29 Jun 2018 11:08:43 -0700 (PDT)
MIME-Version: 1.0
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com> <1530239363-2356-2-git-send-email-hejianet@gmail.com>
In-Reply-To: <1530239363-2356-2-git-send-email-hejianet@gmail.com>
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Date: Fri, 29 Jun 2018 14:08:07 -0400
Message-ID: <CAGM2reZ74Re6-CnAoNqK_VG+AOzs7u4cOUaJ4iMy25Q8P_aXEQ@mail.gmail.com>
Subject: Re: [PATCH v9 1/6] arm: arm64: introduce CONFIG_HAVE_MEMBLOCK_PFN_VALID
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: hejianet@gmail.com
Cc: linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, ard.biesheuvel@linaro.org, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, pombredanne@nexb.com, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, ptesarik@suse.com, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com

On Thu, Jun 28, 2018 at 10:30 PM Jia He <hejianet@gmail.com> wrote:
>
> Make CONFIG_HAVE_MEMBLOCK_PFN_VALID a new config option so it can move
> memblock_next_valid_pfn to generic code file. All the latter optimizations
> are based on this config.
>
> The memblock initialization time on arm/arm64 can benefit from this.
>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>

Reviewed-by: Pavel Tatashin <pasha.tatashin@oracle.com>
On Thu, Jun 28, 2018 at 10:30 PM Jia He <hejianet@gmail.com> wrote:
>
> Make CONFIG_HAVE_MEMBLOCK_PFN_VALID a new config option so it can move
> memblock_next_valid_pfn to generic code file. All the latter optimizations
> are based on this config.
>
> The memblock initialization time on arm/arm64 can benefit from this.
>
> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
> ---
>  arch/arm/Kconfig   | 4 ++++
>  arch/arm64/Kconfig | 4 ++++
>  mm/Kconfig         | 3 +++
>  3 files changed, 11 insertions(+)
>
> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
> index 843edfd..7ea2636 100644
> --- a/arch/arm/Kconfig
> +++ b/arch/arm/Kconfig
> @@ -1642,6 +1642,10 @@ config ARCH_SELECT_MEMORY_MODEL
>  config HAVE_ARCH_PFN_VALID
>         def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
>
> +config HAVE_MEMBLOCK_PFN_VALID
> +       def_bool y
> +       depends on HAVE_ARCH_PFN_VALID
> +
>  config HAVE_GENERIC_GUP
>         def_bool y
>         depends on ARM_LPAE
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 42c090c..26d75f4 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -778,6 +778,10 @@ config ARCH_SELECT_MEMORY_MODEL
>  config HAVE_ARCH_PFN_VALID
>         def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
>
> +config HAVE_MEMBLOCK_PFN_VALID
> +       def_bool y
> +       depends on HAVE_ARCH_PFN_VALID
> +
>  config HW_PERF_EVENTS
>         def_bool y
>         depends on ARM_PMU
> diff --git a/mm/Kconfig b/mm/Kconfig
> index ce95491..2c38080a5 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>         bool
>
> +config HAVE_MEMBLOCK_PFN_VALID
> +       bool
> +
>  config HAVE_GENERIC_GUP
>         bool
>
> --
> 1.8.3.1
>
