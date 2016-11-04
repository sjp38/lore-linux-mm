Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3ABA16B0304
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:58:28 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id n85so17525873pfi.4
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:58:28 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [103.22.144.67])
        by mx.google.com with ESMTPS id j191si13854463pfc.166.2016.11.03.21.58.26
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 21:58:26 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v2 5/7] powerpc: Rename context.vdso_base to context.vdso
In-Reply-To: <20161101171101.24704-5-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org> <20161101171101.24704-5-cov@codeaurora.org>
Date: Fri, 04 Nov 2016 15:58:22 +1100
Message-ID: <87r36rn8nl.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>, criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>, akpm@linux-foundation.orgakpm@linux-foundation.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Christopher Covington <cov@codeaurora.org> writes:

> Checkpoint/Restore In Userspace (CRIU) needs to be able to unmap and remap
> the VDSO to successfully checkpoint and restore applications in the face of
> changing VDSO addresses due to Address Space Layout Randomization (ASLR,
> randmaps). x86 and PowerPC have had architecture-specific code to support
> this. In order to expand the architectures that support this without
> unnecessary duplication of code, a generic version based on the PowerPC code
> was created. It differs slightly, based on the results of an informal
> survey of all architectures that indicated
>
> 	unsigned long vdso;
>
> is popular (and it's also concise). Therefore, change the variable name in
> powerpc from mm->context.vdso_base to mm->context.vdso.
>
> Signed-off-by: Christopher Covington <cov@codeaurora.org>
> ---
>  arch/powerpc/include/asm/book3s/32/mmu-hash.h |  2 +-
>  arch/powerpc/include/asm/book3s/64/mmu.h      |  2 +-
>  arch/powerpc/include/asm/mm-arch-hooks.h      |  6 +++---
>  arch/powerpc/include/asm/mmu-40x.h            |  2 +-
>  arch/powerpc/include/asm/mmu-44x.h            |  2 +-
>  arch/powerpc/include/asm/mmu-8xx.h            |  2 +-
>  arch/powerpc/include/asm/mmu-book3e.h         |  2 +-
>  arch/powerpc/include/asm/mmu_context.h        |  4 ++--
>  arch/powerpc/include/asm/vdso.h               |  2 +-
>  arch/powerpc/include/uapi/asm/elf.h           |  2 +-
>  arch/powerpc/kernel/signal_32.c               |  8 ++++----
>  arch/powerpc/kernel/signal_64.c               |  4 ++--
>  arch/powerpc/kernel/vdso.c                    |  8 ++++----
>  arch/powerpc/perf/callchain.c                 | 12 ++++++------
>  14 files changed, 29 insertions(+), 29 deletions(-)

This is kind of annoying, but I guess it's worth doing.

It's going to conflict like hell though. Who were you thinking would
merge this series? I think it should go via Andrew Morton's tree, as
that way if we get bad conflicts we can pull it out and redo it.

Assuming we agree on that I'm happy to ack it:

Acked-by: Michael Ellerman <mpe@ellerman.id.au> (powerpc)

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
