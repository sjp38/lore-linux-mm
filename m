Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id EECAC6B0033
	for <linux-mm@kvack.org>; Mon,  9 Oct 2017 15:02:12 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n82so8268272oig.1
        for <linux-mm@kvack.org>; Mon, 09 Oct 2017 12:02:12 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id m34si4258409oik.426.2017.10.09.12.02.11
        for <linux-mm@kvack.org>;
        Mon, 09 Oct 2017 12:02:11 -0700 (PDT)
Date: Mon, 9 Oct 2017 20:02:13 +0100
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 09/12] mm/kasan: kasan specific map populate function
Message-ID: <20171009190213.GF30828@arm.com>
References: <20170920201714.19817-1-pasha.tatashin@oracle.com>
 <20170920201714.19817-10-pasha.tatashin@oracle.com>
 <20171003144845.GD4931@leverpostej>
 <20171009171337.GE30085@arm.com>
 <CAOAebxtHHFvYn4WysMASe1GqvgKYPVyjJ572UM3Sef5sP0hi9A@mail.gmail.com>
 <20171009182217.GC30828@arm.com>
 <CAOAebxu1310eCrk88EC=Oaw3n90-9RuHZ1KBhPvLu_DyXBNZFQ@mail.gmail.com>
 <20171009184834.GE30828@arm.com>
 <CAOAebxs5s3DKV8f+Zw+LFVB98PE6cs=RwcOH8qEiU_MPLM9RvQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAOAebxs5s3DKV8f+Zw+LFVB98PE6cs=RwcOH8qEiU_MPLM9RvQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Tatashin <pasha.tatashin@oracle.com>
Cc: Mark Rutland <mark.rutland@arm.com>, catalin.marinas@arm.com, linux-kernel@vger.kernel.org, sparclinux@vger.kernel.org, linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-s390@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, kasan-dev@googlegroups.com, borntraeger@de.ibm.com, heiko.carstens@de.ibm.com, davem@davemloft.net, willy@infradead.org, mhocko@kernel.org, Ard Biesheuvel <ard.biesheuvel@linaro.org>, sam@ravnborg.org, mgorman@techsingularity.net, Steve Sistare <steven.sistare@oracle.com>, daniel.m.jordan@oracle.com, bob.picco@oracle.com

Hi Pavel,

On Mon, Oct 09, 2017 at 02:59:09PM -0400, Pavel Tatashin wrote:
> > We have two table walks even with your patch series applied afaict: one in
> > our definition of vmemmap_populate (arch/arm64/mm/mmu.c) and this one
> > in the core code.
> 
> I meant to say implementing two new page table walkers, not at runtime.

Ok, but I'm still missing why you think that is needed. What would be the
second page table walker that needs implementing?

> > My worry is that these are actually highly arch-specific, but will likely
> > grow more users in mm/ that assume things for all architectures that aren't
> > necessarily valid.
> 
> I see, how about moving new kasan_map_populate() implementation into
> arch dependent code:
> 
> arch/x86/mm/kasan_init_64.c
> arch/arm64/mm/kasan_init.c
> 
> This way we won't need to add pmd_large()/pud_large() macros for arm64?

I guess we could implement that on arm64 using our current vmemmap_populate
logic and an explicit memset.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
