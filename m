Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 0F7EE6B0023
	for <linux-mm@kvack.org>; Mon,  2 Apr 2018 04:12:44 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f3-v6so4766087plf.1
        for <linux-mm@kvack.org>; Mon, 02 Apr 2018 01:12:44 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id x63sor3848621pgb.204.2018.04.02.01.12.42
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Mon, 02 Apr 2018 01:12:42 -0700 (PDT)
Date: Mon, 2 Apr 2018 16:12:33 +0800
From: Wei Yang <richard.weiyang@gmail.com>
Subject: Re: [PATCH v3 1/5] mm: page_alloc: remain memblock_next_valid_pfn()
 when CONFIG_HAVE_ARCH_PFN_VALID is enable
Message-ID: <20180402081233.GA38180@WeideMacBook-Pro.local>
Reply-To: Wei Yang <richard.weiyang@gmail.com>
References: <1522033340-6575-1-git-send-email-hejianet@gmail.com>
 <1522033340-6575-2-git-send-email-hejianet@gmail.com>
 <20180328091800.GB97260@WeideMacBook-Pro.local>
 <f8e7eaca-e9f1-0ed1-a9f9-1dff81b13814@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <f8e7eaca-e9f1-0ed1-a9f9-1dff81b13814@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jia He <hejianet@gmail.com>
Cc: Wei Yang <richard.weiyang@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Catalin Marinas <catalin.marinas@arm.com>, Mel Gorman <mgorman@suse.de>, Will Deacon <will.deacon@arm.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, AKASHI Takahiro <takahiro.akashi@linaro.org>, Gioh Kim <gi-oh.kim@profitbricks.com>, Steven Sistare <steven.sistare@oracle.com>, Daniel Vacek <neelx@redhat.com>, Eugeniu Rosca <erosca@de.adit-jv.com>, Vlastimil Babka <vbabka@suse.cz>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, James Morse <james.morse@arm.com>, Steve Capper <steve.capper@arm.com>, x86@kernel.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Kate Stewart <kstewart@linuxfoundation.org>, Philippe Ombredanne <pombredanne@nexb.com>, Johannes Weiner <hannes@cmpxchg.org>, Kemi Wang <kemi.wang@intel.com>, Petr Tesarik <ptesarik@suse.com>, YASUAKI ISHIMATSU <yasu.isimatu@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Nikolay Borisov <nborisov@suse.com>, Jia He <jia.he@hxt-semitech.com>

On Wed, Mar 28, 2018 at 05:49:23PM +0800, Jia He wrote:
>
>
>On 3/28/2018 5:18 PM, Wei Yang Wrote:
>> Oops, I should reply this thread. Forget about the reply on another thread.
>> 
>> On Sun, Mar 25, 2018 at 08:02:15PM -0700, Jia He wrote:
>> > Commit b92df1de5d28 ("mm: page_alloc: skip over regions of invalid pfns
>> > where possible") optimized the loop in memmap_init_zone(). But it causes
>> > possible panic bug. So Daniel Vacek reverted it later.
>> > 
>> Why this has a bug? Do you have some link about it?
>> 
>> If the audience could know the potential risk, it would be helpful to review
>> the code and decide whether to take it back.
>Hi Wei
>Paul firstly submit a commit b92df1de5 to improve the loop in
>memmap_init_zone.
>And Daniel tried to fix a bug_on panic issue on X86 in commit 864b75f9d6b
>because
>there is evidence that this bug_on was caused by b92df1de5 [1].
>
>But things didn't get better, 864b75f9d6b caused booting hang issue on
>arm{64} [2]
>So maintainer decided to reverted both b92df1de5 and 864b75f9d6b
>
>[1] https://patchwork.kernel.org/patch/10251145/
>[2] https://lkml.org/lkml/2018/3/14/469

I took some time to look into the discussion, while the root cause seems not
clear now?

-- 
Wei Yang
Help you, Help me
