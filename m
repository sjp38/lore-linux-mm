Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 4CF2F6B0348
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 16:13:33 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id l66so23638199pfl.7
        for <linux-mm@kvack.org>; Fri, 04 Nov 2016 13:13:33 -0700 (PDT)
Received: from foss.arm.com (foss.arm.com. [217.140.101.70])
        by mx.google.com with ESMTP id 123si18400276pgj.89.2016.11.04.13.13.32
        for <linux-mm@kvack.org>;
        Fri, 04 Nov 2016 13:13:32 -0700 (PDT)
Date: Fri, 4 Nov 2016 20:13:32 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [RFC v2 5/7] powerpc: Rename context.vdso_base to context.vdso
Message-ID: <20161104201332.GB22791@arm.com>
References: <20161101171101.24704-1-cov@codeaurora.org>
 <20161101171101.24704-5-cov@codeaurora.org>
 <87r36rn8nl.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <87r36rn8nl.fsf@concordia.ellerman.id.au>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michael Ellerman <mpe@ellerman.id.au>
Cc: Christopher Covington <cov@codeaurora.org>, criu@openvz.org, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

[fixing akpm's email address]

On Fri, Nov 04, 2016 at 03:58:22PM +1100, Michael Ellerman wrote:
> Christopher Covington <cov@codeaurora.org> writes:
> 
> > Checkpoint/Restore In Userspace (CRIU) needs to be able to unmap and remap
> > the VDSO to successfully checkpoint and restore applications in the face of
> > changing VDSO addresses due to Address Space Layout Randomization (ASLR,
> > randmaps). x86 and PowerPC have had architecture-specific code to support
> > this. In order to expand the architectures that support this without
> > unnecessary duplication of code, a generic version based on the PowerPC code
> > was created. It differs slightly, based on the results of an informal
> > survey of all architectures that indicated
> >
> > 	unsigned long vdso;
> >
> > is popular (and it's also concise). Therefore, change the variable name in
> > powerpc from mm->context.vdso_base to mm->context.vdso.
> >
> > Signed-off-by: Christopher Covington <cov@codeaurora.org>
> > ---
> >  arch/powerpc/include/asm/book3s/32/mmu-hash.h |  2 +-
> >  arch/powerpc/include/asm/book3s/64/mmu.h      |  2 +-
> >  arch/powerpc/include/asm/mm-arch-hooks.h      |  6 +++---
> >  arch/powerpc/include/asm/mmu-40x.h            |  2 +-
> >  arch/powerpc/include/asm/mmu-44x.h            |  2 +-
> >  arch/powerpc/include/asm/mmu-8xx.h            |  2 +-
> >  arch/powerpc/include/asm/mmu-book3e.h         |  2 +-
> >  arch/powerpc/include/asm/mmu_context.h        |  4 ++--
> >  arch/powerpc/include/asm/vdso.h               |  2 +-
> >  arch/powerpc/include/uapi/asm/elf.h           |  2 +-
> >  arch/powerpc/kernel/signal_32.c               |  8 ++++----
> >  arch/powerpc/kernel/signal_64.c               |  4 ++--
> >  arch/powerpc/kernel/vdso.c                    |  8 ++++----
> >  arch/powerpc/perf/callchain.c                 | 12 ++++++------
> >  14 files changed, 29 insertions(+), 29 deletions(-)
> 
> This is kind of annoying, but I guess it's worth doing.
> 
> It's going to conflict like hell though. Who were you thinking would
> merge this series? I think it should go via Andrew Morton's tree, as
> that way if we get bad conflicts we can pull it out and redo it.

The other thing you can do is generate the patch towards the end of the
merge window and send it as a separate pull request. The disadvantage of
that is that it can't spend any time in -next, but that might be ok for a
mechanical rename.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
