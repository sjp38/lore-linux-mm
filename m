Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f199.google.com (mail-io0-f199.google.com [209.85.223.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2492B6B000A
	for <linux-mm@kvack.org>; Wed, 21 Mar 2018 08:04:45 -0400 (EDT)
Received: by mail-io0-f199.google.com with SMTP id t27so4154973iob.20
        for <linux-mm@kvack.org>; Wed, 21 Mar 2018 05:04:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id 38sor1738458iol.347.2018.03.21.05.04.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 21 Mar 2018 05:04:44 -0700 (PDT)
Subject: Re: [PATCH 2/4] mm/memblock: introduce memblock_search_pfn_regions()
References: <1521619796-3846-1-git-send-email-hejianet@gmail.com>
 <1521619796-3846-3-git-send-email-hejianet@gmail.com>
 <CACjP9X94yUxYWimmq1re7oTxhQUfbduVoJ0=iqPiWqV0cjUKng@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <e7e399f0-93d9-eef5-da7b-42df2d4417d8@gmail.com>
Date: Wed, 21 Mar 2018 20:04:22 +0800
MIME-Version: 1.0
In-Reply-To: <CACjP9X94yUxYWimmq1re7oTxhQUfbduVoJ0=iqPiWqV0cjUKng@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

Hi Daniel

Thanks for the review


On 3/21/2018 6:14 PM, Daniel Vacek Wrote:
> On Wed, Mar 21, 2018 at 9:09 AM, Jia He <hejianet@gmail.com> wrote:
>> This api is the preparation for further optimizing early_pfn_valid
>>
>> Signed-off-by: Jia He <jia.he@hxt-semitech.com>
>> ---
>>   include/linux/memblock.h |  2 ++
>>   mm/memblock.c            | 12 ++++++++++++
>>   2 files changed, 14 insertions(+)
>>
>> diff --git a/include/linux/memblock.h b/include/linux/memblock.h
>> index 9471db4..5f46956 100644
>> --- a/include/linux/memblock.h
>> +++ b/include/linux/memblock.h
>> @@ -203,6 +203,8 @@ void __next_mem_pfn_range(int *idx, int nid, unsigned long *out_start_pfn,
>>               i >= 0; __next_mem_pfn_range(&i, nid, p_start, p_end, p_nid))
>>   #endif /* CONFIG_HAVE_MEMBLOCK_NODE_MAP */
>>
>> +int memblock_search_pfn_regions(unsigned long pfn);
>> +
>>   unsigned long memblock_next_valid_pfn(unsigned long pfn, int *last_idx);
>>   /**
>>    * for_each_free_mem_range - iterate through free memblock areas
>> diff --git a/mm/memblock.c b/mm/memblock.c
>> index a9e8da4..f50fe5b 100644
>> --- a/mm/memblock.c
>> +++ b/mm/memblock.c
>> @@ -1659,6 +1659,18 @@ static int __init_memblock memblock_search(struct memblock_type *type, phys_addr
>>          return -1;
>>   }
>>
>> +/* search memblock with the input pfn, return the region idx */
>> +int __init_memblock memblock_search_pfn_regions(unsigned long pfn)
>> +{
>> +       struct memblock_type *type = &memblock.memory;
>> +       int mid = memblock_search(type, PFN_PHYS(pfn));
>> +
>> +       if (mid == -1)
>> +               return -1;
> Why this?
Yes, it is redudant and can be removed.
Thanks

Cheers,
Jia
