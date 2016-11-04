Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f72.google.com (mail-pa0-f72.google.com [209.85.220.72])
	by kanga.kvack.org (Postfix) with ESMTP id 699B3280273
	for <linux-mm@kvack.org>; Fri,  4 Nov 2016 00:59:46 -0400 (EDT)
Received: by mail-pa0-f72.google.com with SMTP id ro13so33230316pac.7
        for <linux-mm@kvack.org>; Thu, 03 Nov 2016 21:59:46 -0700 (PDT)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id k16si3378810pag.60.2016.11.03.21.59.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Nov 2016 21:59:45 -0700 (PDT)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v2 6/7] mm/powerpc: Use generic VDSO remap and unmap functions
In-Reply-To: <20161101171101.24704-6-cov@codeaurora.org>
References: <20161101171101.24704-1-cov@codeaurora.org> <20161101171101.24704-6-cov@codeaurora.org>
Date: Fri, 04 Nov 2016 15:59:43 +1100
Message-ID: <87oa1vn8lc.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christopher Covington <cov@codeaurora.org>, criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org, Laurent Dufour <ldufour@linux.vnet.ibm.com>
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Christopher Covington <cov@codeaurora.org> writes:

> The PowerPC VDSO remap and unmap code was copied to a generic location,
> only modifying the variable name expected in mm->context (vdso instead of
> vdso_base) to match most other architectures. Having adopted this generic
> naming, drop the code in arch/powerpc and use the generic version.
>
> Signed-off-by: Christopher Covington <cov@codeaurora.org>
> ---
>  arch/powerpc/Kconfig                     |  1 +
>  arch/powerpc/include/asm/Kbuild          |  1 +
>  arch/powerpc/include/asm/mm-arch-hooks.h | 28 -------------------------
>  arch/powerpc/include/asm/mmu_context.h   | 35 +-------------------------------
>  4 files changed, 3 insertions(+), 62 deletions(-)
>  delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h

This looks OK.

Have you tested it on powerpc? I could but I don't know how to actually
trigger these paths, I assume I need a CRIU setup?

Can you flip the subject to "powerpc/mm: ...".

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
