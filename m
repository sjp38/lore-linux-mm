Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f71.google.com (mail-pl0-f71.google.com [209.85.160.71])
	by kanga.kvack.org (Postfix) with ESMTP id 789B96B0006
	for <linux-mm@kvack.org>; Thu,  5 Apr 2018 08:29:54 -0400 (EDT)
Received: by mail-pl0-f71.google.com with SMTP id u7-v6so15256319plr.13
        for <linux-mm@kvack.org>; Thu, 05 Apr 2018 05:29:54 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f1-v6sor1299926pld.77.2018.04.05.05.29.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 05 Apr 2018 05:29:53 -0700 (PDT)
Subject: Re: [PATCH v7 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 on arm and arm64
References: <1522915478-5044-1-git-send-email-hejianet@gmail.com>
 <1522915478-5044-2-git-send-email-hejianet@gmail.com>
 <20180405112357.GA2647@bombadil.infradead.org>
From: Jia He <hejianet@gmail.com>
Message-ID: <fda3d3d4-b1da-6020-4257-1c8819800930@gmail.com>
Date: Thu, 5 Apr 2018 20:29:30 +0800
MIME-Version: 1.0
In-Reply-To: <20180405112357.GA2647@bombadil.infradead.org>
Content-Type: text/plain; charset=gbk; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Russell King <linux@armlinux.org.uk>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Wei Yang <richard.weiyang@gmail.com>, Kees Cook <keescook@chromium.org>, Laura Abbott <labbott@redhat.com>, Vladimir Murzin <vladimir.murzin@arm.com>, Philip Derrin <philip@cog.systems>, AKASHI Takahiro <takahiro.akashi@linaro.org>, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Gioh Kim <gi-oh.kim@profitbricks.com>, Vlastimil Babka <vbabka@suse.cz>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Jia He <jia.he@hxt-semitech.com>

Thanks, Matthew


On 4/5/2018 7:23 PM, Matthew Wilcox Wrote:
> On Thu, Apr 05, 2018 at 01:04:34AM -0700, Jia He wrote:
>>   create mode 100644 include/linux/arm96_common.h
> 'arm96_common'?!  No.  Just no.
>
> The right way to share common code is to create a header file (or use
> an existing one), either in asm-generic or linux, with a #ifdef CONFIG_foo
> block and then 'select foo' in the arm Kconfig files.  That allows this
> common code to be shared, maybe with powerpc or x86 or ... in the future.
>
ok
How about include/asm-generic/early_pfn.h ?
And could I use CONFIG_HAVE_ARCH_PFN_VALID and CONFIG_HAVE_MEMBLOCKin 
this case?
Currently, arm/arm64 have memblock enable by default. When other arches 
implement
their HAVE_MEMBLOCK and HAVE_ARCH_PFN_VALID, they can include this file?

-- 
Cheers,
Jia
