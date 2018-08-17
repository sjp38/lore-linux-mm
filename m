Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 852D56B0691
	for <linux-mm@kvack.org>; Fri, 17 Aug 2018 01:38:39 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id u8-v6so3123870pfn.18
        for <linux-mm@kvack.org>; Thu, 16 Aug 2018 22:38:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h9-v6sor319600pfn.70.2018.08.16.22.38.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 16 Aug 2018 22:38:38 -0700 (PDT)
Subject: Re: [RESEND PATCH v10 6/6] mm: page_alloc: reduce unnecessary binary
 search in early_pfn_valid()
References: <1530867675-9018-1-git-send-email-hejianet@gmail.com>
 <1530867675-9018-7-git-send-email-hejianet@gmail.com>
 <c6ed43ee-b09e-1f75-43b3-6cd2808d13f3@microsoft.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <f69a37b8-3e19-e12b-a51b-2cb62a326bcc@gmail.com>
Date: Fri, 17 Aug 2018 13:38:25 +0800
MIME-Version: 1.0
In-Reply-To: <c6ed43ee-b09e-1f75-43b3-6cd2808d13f3@microsoft.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pasha Tatashin <Pavel.Tatashin@microsoft.com>, Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>

Hi Pasha
Thanks for the comments

On 8/17/2018 9:35 AM, Pasha Tatashin Wrote:
> 
> 
> On 7/6/18 5:01 AM, Jia He wrote:
>> Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> where possible") optimized the loop in memmap_init_zone(). But there is
>> still some room for improvement. E.g. in early_pfn_valid(), if pfn and
>> pfn+1 are in the same memblock region, we can record the last returned
>> memblock region index and check whether pfn++ is still in the same
>> region.
>>
>> Currently it only improve the performance on arm/arm64 and will have no
>> impact on other arches.
>>
>> For the performance improvement, after this set, I can see the time
>> overhead of memmap_init() is reduced from 27956us to 13537us in my
>> armv8a server(QDF2400 with 96G memory, pagesize 64k).
> 
> This series would be a lot simpler if patches 4, 5, and 6 were dropped.
> The extra complexity does not make sense to save 0.0001s/T during not.
> 
> Patches 1-3, look OK, but without patches 4-5 __init_memblock should be
> made local static as I suggested earlier.
> 
> So, I think Jia should re-spin this series with only 3 patches. Or,
> Andrew could remove the from linux-next before merge.
> 
I will respin it with #1-#3 patch if no more comments

Cheers,
Jia
> Thank you,
> Pavel
> 
