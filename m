Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id C20A16B1D37
	for <linux-mm@kvack.org>; Tue, 21 Aug 2018 02:14:54 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f66-v6so11213506plb.10
        for <linux-mm@kvack.org>; Mon, 20 Aug 2018 23:14:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id w24-v6sor2615074pgj.410.2018.08.20.23.14.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 20 Aug 2018 23:14:53 -0700 (PDT)
Subject: Re: [RESEND PATCH v10 3/6] mm: page_alloc: reduce unnecessary binary
 search in memblock_next_valid_pfn()
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-4-git-send-email-hejianet@gmail.com>
 <61ca29b9-a985-cce0-03e9-d216791c802c@microsoft.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <334337ca-811e-4a2e-09ff-65ebe37ef6df@gmail.com>
Date: Tue, 21 Aug 2018 14:14:30 +0800
MIME-Version: 1.0
In-Reply-To: <61ca29b9-a985-cce0-03e9-d216791c802c@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

Hi Pasha

On 8/17/2018 9:08 AM, Pasha Tatashin Wrote:
> 
>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>> ---
>>  mm/memblock.c | 37 +++++++++++++++++++++++++++++--------
>>  1 file changed, 29 insertions(+), 8 deletions(-)
>>
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index ccad225..84f7fa7 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1140,31 +1140,52 @@ int __init_memblock memblock_set_node(phys_addr_t base, phys_addr_t size,
>>  #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>  
>>  #ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
>> +static int early_region_idx __init_memblock = -1;
> 
> One comment:
> 
> This should be __initdata, but even better bring it inside the function
> as local static variable.
> 
Seems it should be __initdata_memblock instead of __initdata?

-- 
Cheers,
Jia
>>  ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
>>  {
> 
> Otherwise looks good:
> 
> Reviewed-by: Pavel Tatashin <pavel.tatashin@microsoft.com>
> 
