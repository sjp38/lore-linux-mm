Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 2ADD06B0006
	for <linux-mm@kvack.org>; Tue, 27 Mar 2018 21:50:23 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d14-v6so623286plj.4
        for <linux-mm@kvack.org>; Tue, 27 Mar 2018 18:50:23 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id ay8-v6sor1225084plb.120.2018.03.27.18.50.21
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 27 Mar 2018 18:50:21 -0700 (PDT)
Subject: Re: [PATCH v2 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 when CONFIG_HAVE_ARCH_PFN_VALID is enable
References: <1521894282-6454-1-git-send-email-hejianet@gmail.com>
 <1521894282-6454-2-git-send-email-hejianet@gmail.com>
 <CACjP9X-zvGa5OQpuJ1bUp+V=_eTOUDLfKkT1sbT84k5zJz=epA@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <0a8ba07b-b046-c1b4-9c4e-74d7b5dc370e@gmail.com>
Date: Wed, 28 Mar 2018 09:49:53 +0800
MIME-Version: 1.0
In-Reply-To: <CACjP9X-zvGa5OQpuJ1bUp+V=_eTOUDLfKkT1sbT84k5zJz=epA@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Vacek <neelx@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, open list <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>



On 3/28/2018 12:52 AM, Daniel Vacek Wrote:
> On Sat, Mar 24, 2018 at 1:24 PM, Jia He <hejianet@gmail.com> wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But it causes
>> possible panic bug. So Daniel Vacek reverted it later.
>>
>> But memblock_next_valid_pfn is valid when CONFIG_HAVE_ARCH_PFN_VALID is
>> enabled. And as verified by Eugeniu Rosca, arm can benifit from this
>> commit. So remain the memblock_next_valid_pfn.
> It is not dependent on CONFIG_HAVE_ARCH_PFN_VALID option but on
> arm(64) implementation of pfn_valid() function, IIUC. So it should
> really be moved from generic source file to arm specific location. I'd
> say somewhere close to the pfn_valid() implementation. Such as to
> arch/arm{,64}/mm/ init.c-ish?
>
> --nX
Ok, thanks for your suggestions.
I will try to move theA  related codes to arm arch directory.

Cheer,
Jia
