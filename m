Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id BA7216B02AC
	for <linux-mm@kvack.org>; Mon,  2 Jul 2018 21:55:39 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id p91-v6so283778plb.12
        for <linux-mm@kvack.org>; Mon, 02 Jul 2018 18:55:39 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id k1-v6sor5413370plt.102.2018.07.02.18.55.38
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Jul 2018 18:55:38 -0700 (PDT)
Subject: Re: [PATCH v9 2/6] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm/arm64
References: <1530239363-2356-1-git-send-email-hejianet@gmail.com>
 <1530239363-2356-3-git-send-email-hejianet@gmail.com>
 <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <bfe24a3b-c982-9532-c05b-f42ebb77bbba@gmail.com>
Date: Tue, 3 Jul 2018 09:55:18 +0800
MIME-Version: 1.0
In-Reply-To: <CAGM2reYn3ZbdjhcZze8Zt1eLNSdWghy0KwEXfd5xW+1Ba_SMbw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: linux@armlinux.org.uk, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, will.deacon@arm.com, mark.rutland@arm.com, hpa@zytor.com, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, neelx@redhat.com, erosca@de.adit-jv.com, Vlastimil Babka <vbabka@suse.cz>, LKML <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, james.morse@arm.com, ard.biesheuvel@linaro.org, steve.capper@arm.com, tglx@linutronix.de, mingo@redhat.com, gregkh@linuxfoundation.org, kstewart@linuxfoundation.org, pombredanne@nexb.com, Johannes Weiner <hannes@cmpxchg.org>, kemi.wang@intel.com, ptesarik@suse.com, yasu.isimatu@gmail.com, aryabinin@virtuozzo.com, nborisov@suse.com, Wei Yang <richard.weiyang@gmail.com>, jia.he@hxt-semitech.com

Hi, Pavel
Thanks for the comments.

On 6/30/2018 2:13 AM, Pavel Tatashin Wrote:
>> +++ b/include/linux/early_pfn.h
>> @@ -0,0 +1,34 @@
>> +/* SPDX-License-Identifier: GPL-2.0 */
>> +/* Copyright (C) 2018 HXT-semitech Corp. */
>> +#ifndef __EARLY_PFN_H
>> +#define __EARLY_PFN_H
>> +#ifdef CONFIG_HAVE_MEMBLOCK_PFN_VALID
>> +ulong __init_memblock memblock_next_valid_pfn(ulong pfn)
>> +{
>> +       struct memblock_type *type = &memblock.memory;
> 
> Why put it in a header file and not in some C file? In my opinion it
> is confusing to have non-line functions in header files. Basically,
> you can include this header file in exactly one C file without
> breaking compilation.
> 
My original intent is to make this helper memblock_next_valid_pfn
a common api between arm64 and arm arches since both arches will
use enable CONFIG_HAVE_MEMBLOCK_PFN_VALID by default.

Do you think it looks ok if I add the inline prefix?

-- 
Cheers,
Jia
