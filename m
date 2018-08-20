Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f197.google.com (mail-pg1-f197.google.com [209.85.215.197])
	by kanga.kvack.org (Postfix) with ESMTP id 1C81D6B1782
	for <linux-mm@kvack.org>; Mon, 20 Aug 2018 02:27:35 -0400 (EDT)
Received: by mail-pg1-f197.google.com with SMTP id r20-v6so5707297pgv.20
        for <linux-mm@kvack.org>; Sun, 19 Aug 2018 23:27:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n2-v6sor2115827pgj.369.2018.08.19.23.27.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 19 Aug 2018 23:27:34 -0700 (PDT)
Subject: Re: [RESEND PATCH v10 1/6] arm: arm64: introduce
 CONFIG_HAVE_MEMBLOCK_PFN_VALID
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-2-git-send-email-hejianet@gmail.com>
 <20180817145052.aizhi6n66vxblriq@armageddon.cambridge.arm.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <73e1f356-2b6c-a7fd-2f04-e5b58ae79884@gmail.com>
Date: Mon, 20 Aug 2018 14:27:22 +0800
MIME-Version: 1.0
In-Reply-To: <20180817145052.aizhi6n66vxblriq@armageddon.cambridge.arm.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Russell King <linux@armlinux.org.uk>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Wei Yang <richard.weiyang@gmail.com>, linux-mm@kvack.org, Eugeniu Rosca <erosca@de.adit-jv.com>, Petr Tesarik <ptesarik@suse.com>, Nikolay Borisov <nborisov@suse.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Vlastimil Babka <vbabka@suse.cz>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Laura Abbott <labbott@redhat.com>, Daniel Vacek <neelx@redhat.com>, Mel Gorman <mgorman@suse.de>, Vladimir Murzin <vladimir.murzin@arm.com>, Kees Cook <keescook@chromium.org>, Philip Derrin <philip@cog.systems>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Jia He <jia.he@hxt-semitech.com>, Kemi Wang <kemi.wang@intel.com>, linux-arm-kernel@lists.infradead.org, Steve Capper <steve.capper@arm.com>, linux-kernel@vger.kernel.org, James Morse <james.morse@arm.com>, Johannes Weiner <hannes@cmpxchg.org>



On 8/17/2018 10:50 PM, Catalin Marinas Wrote:
> On Fri, Jul 06, 2018 at 05:01:10PM +0800, Jia He wrote:
>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 42c090c..26d75f4 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -778,6 +778,10 @@ config ARCH_SELECT_MEMORY_MODEL
>>  config HAVE_ARCH_PFN_VALID
>>  	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
>>  
>> +config HAVE_MEMBLOCK_PFN_VALID
>> +	def_bool y
>> +	depends on HAVE_ARCH_PFN_VALID
>> +
>>  config HW_PERF_EVENTS
>>  	def_bool y
>>  	depends on ARM_PMU
>> diff --git a/mm/Kconfig b/mm/Kconfig
>> index 94af022..28fcf54 100644
>> --- a/mm/Kconfig
>> +++ b/mm/Kconfig
>> @@ -137,6 +137,9 @@ config HAVE_MEMBLOCK_NODE_MAP
>>  config HAVE_MEMBLOCK_PHYS_MAP
>>  	bool
>>  
>> +config HAVE_MEMBLOCK_PFN_VALID
>> +	bool
> 
> Since you defined HAVE_MEMBLOCK_PFN_VALID here, do we need to define it
> in the arch code as well? If kept it in the mm/Kconfig only, you could
> just select it in the arch HAVE_ARCH_PFN_VALID entry:
> 

Ok, thanks for the comments
It makes it more clean.
-- 
Cheers,
Jia

> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
> index d0a53cc6293a..cd230c77e122 100644
> --- a/arch/arm64/Kconfig
> +++ b/arch/arm64/Kconfig
> @@ -787,6 +787,7 @@ config ARCH_FLATMEM_ENABLE
>  
>  config HAVE_ARCH_PFN_VALID
>  	def_bool ARCH_HAS_HOLES_MEMORYMODEL || !SPARSEMEM
> +	select HAVE_MEMBLOCK_PFN_VALID
>  
>  config HW_PERF_EVENTS
>  	def_bool y
> 
> (similarly for arch/arm)
> 
