Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DAD7F6B0069
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 03:01:11 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id n85so46006634pfi.4
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 00:01:11 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id i68si29914697pgc.178.2016.11.07.00.01.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 00:01:10 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v2 5/7] powerpc: Rename context.vdso_base to context.vdso
In-Reply-To: <20161104201332.GB22791@arm.com>
References: <20161101171101.24704-1-cov@codeaurora.org> <20161101171101.24704-5-cov@codeaurora.org> <87r36rn8nl.fsf@concordia.ellerman.id.au> <20161104201332.GB22791@arm.com>
Date: Mon, 07 Nov 2016 19:01:05 +1100
Message-ID: <87a8dbn2gu.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>
Cc: Christopher Covington <cov@codeaurora.org>, criu@openvz.org, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Will Deacon <will.deacon@arm.com> writes:
> On Fri, Nov 04, 2016 at 03:58:22PM +1100, Michael Ellerman wrote:
>> Christopher Covington <cov@codeaurora.org> writes:
>> >  arch/powerpc/include/asm/book3s/32/mmu-hash.h |  2 +-
>> >  arch/powerpc/include/asm/book3s/64/mmu.h      |  2 +-
>> >  arch/powerpc/include/asm/mm-arch-hooks.h      |  6 +++---
>> >  arch/powerpc/include/asm/mmu-40x.h            |  2 +-
>> >  arch/powerpc/include/asm/mmu-44x.h            |  2 +-
>> >  arch/powerpc/include/asm/mmu-8xx.h            |  2 +-
>> >  arch/powerpc/include/asm/mmu-book3e.h         |  2 +-
>> >  arch/powerpc/include/asm/mmu_context.h        |  4 ++--
>> >  arch/powerpc/include/asm/vdso.h               |  2 +-
>> >  arch/powerpc/include/uapi/asm/elf.h           |  2 +-
>> >  arch/powerpc/kernel/signal_32.c               |  8 ++++----
>> >  arch/powerpc/kernel/signal_64.c               |  4 ++--
>> >  arch/powerpc/kernel/vdso.c                    |  8 ++++----
>> >  arch/powerpc/perf/callchain.c                 | 12 ++++++------
>> >  14 files changed, 29 insertions(+), 29 deletions(-)
>> 
>> This is kind of annoying, but I guess it's worth doing.
>> 
>> It's going to conflict like hell though. Who were you thinking would
>> merge this series? I think it should go via Andrew Morton's tree, as
>> that way if we get bad conflicts we can pull it out and redo it.
>
> The other thing you can do is generate the patch towards the end of the
> merge window and send it as a separate pull request. The disadvantage of
> that is that it can't spend any time in -next, but that might be ok for a
> mechanical rename.

True. Though in this case it's a mechanical rename that then allows us
to use the generic code, so I'd prefer we had some -next coverage on the
latter.

The other other option would be to wrap all uses of the arch value in a
macro (or actually two probably, one a getter one a setter). That would
then allow arches to use the generic code regardless of the name and
type of their mm->context.vdso_whatever.

That would allow the basic series to go in, and then each arch could do
a series later that switches it to the "standard" name and type.

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
