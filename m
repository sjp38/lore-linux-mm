Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 2BB5E6B0025
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 04:15:29 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id p10so12162079pfl.22
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 01:15:29 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id az2-v6sor6564778plb.24.2018.04.02.01.15.28
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 01:15:28 -0700 (PDT)
Subject: Re: [PATCH v5 5/5] mm: page_alloc: reduce unnecessary binary search
 in early_pfn_valid()
References: <1522636236-12625-1-git-send-email-hejianet@gmail.com>
 <1522636236-12625-6-git-send-email-hejianet@gmail.com>
 <CAKv+Gu9jSXq7YN68Mk7WV4+aLr=nRtHmuQnHMdM8YhgeA-SYsg@mail.gmail.com>
From: Jia He <hejianet@gmail.com>
Message-ID: <75088758-f59c-c65a-6e88-116c1e6b6675@gmail.com>
Date: Mon, 2 Apr 2018 16:15:09 +0800
MIME-Version: 1.0
In-Reply-To: <CAKv+Gu9jSXq7YN68Mk7WV4+aLr=nRtHmuQnHMdM8YhgeA-SYsg@mail.gmail.com>
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel <linux-arm-kernel@lists.infradead.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux-MM <linux-mm@kvack.org>, Jia He <jia.he@hxt-semitech.com>



On 4/2/2018 3:00 PM, Ard Biesheuvel Wrote:
> How much does it improve the performance? And in which cases?
>
> I guess it improves boot time on systems with physical address spaces
> that are sparsely populated with DRAM, but you really have to quantify
> this if you want other people to care.
Yes, I write the performance in patch 0/5. I will write it in the patch 
description later.

-- 
Cheers,
Jia
