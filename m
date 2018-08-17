Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8F2626B08C4
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 10:51:02 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id b8-v6so7335441oib.4
        for <linux-mm@kvack.org>; Fri, 17 Aug 2018 07:51:02 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id w10-v6si1687558oig.308.2018.08.17.07.51.01
        for <linux-mm@kvack.org>;
        Fri, 17 Aug 2018 07:51:01 -0700 (PDT)
Date: Fri, 17 Aug 2018 15:50:53 +0100
From: Catalin Marinas <catalin.marinas@arm.com>
Subject: Re: [RESEND PATCH v10 1/6] arm: arm64: introduce
 CONFIG_HAVE_MEMBLOCK_PFN_VALID
Message-ID: <20180817145052.aizhi6n66vxblriq@armageddon.cambridge.arm.com>
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-2-git-send-email-hejianet@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1530867675-9018-2-git-send-email-hejianet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Eugeniu Rosca <erosca@de.adit-jv.com>, Petr Tesarik <ptesarik@suse.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Laura Abbott <labbott@redhat.com>, Daniel Vacek <neelx@redhat.com>, Mel Gorman <mgorman@suse.de>, Vladimir Murzin <vladimir.murzin@arm.com>, Kees Cook <keescook@chromium.org>, Philip Derrin <philip@cog.systems>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Jia He <jia.he@hxt-semitech.com>, Kemi Wang <kemi.wang@intel.com>, linux-arm-kernel@lists.infradead.org, Steve Capper <steve.capper@arm.com>, linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>, Johannes Weiner <hannes@cmpxchg.org>

On Fri, Jul 06, 2018 at 05:01:10PM +0800, Jia He wrote:
> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index 42c090c..26d75f4 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -778,6 +778,10 @@ config ARCH_SELECT_MEMORY_MODEL
>  config HAVE_ARCH_PFN_VALID
>  	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
>  
> +config HAVE_MEMBLOCK_PFN_VALID
> +	def_bool y
> +	depends on HAVE_ARCH_PFN_VALID
> +
>  config HW_PERF_EVENTS
>  	def_bool y
>  	depends on ARM_PMU
> diff --git a/mm/Kconfig b/mm/Kconfig
> index 94af022..28fcf54 100644
> --- a/mm/Kconfig
> +++ b/mm/Kconfig
> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>  config HAVE_MEMBLOCK_PHYS_MAP
>  	bool
>  
> +config HAVE_MEMBLOCK_PFN_VALID
> +	bool

Since you defined HAVE_MEMBLOCK_PFN_VALID here, do we need to define it
in the arch code as well? If kept it in the mm/Kconfig only, you could
just select it in the arch HAVE_ARCH_PFN_VALID entry:

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index d0a53cc6293a..cd230c77e122 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -787,6 +787,7 @@ config ARCH_FLATMEM_ENABLE
 
 config HAVE_ARCH_PFN_VALID
 	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
+	select HAVE_MEMBLOCK_PFN_VALID
 
 config HW_PERF_EVENTS
 	def_bool y

(similarly for arch/arm)

-- 
Catalin
