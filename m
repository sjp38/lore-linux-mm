Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3D7F86B0253
	for <linux-mm@kvack.org>; Mon,  7 Nov 2016 18:58:30 -0500 (EST)
Received: by mail-pf0-f199.google.com with SMTP id 17so58453307pfy.2
        for <linux-mm@kvack.org>; Mon, 07 Nov 2016 15:58:30 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id 1si33583672pgr.30.2016.11.07.15.51.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 07 Nov 2016 15:51:58 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [RFC v2 6/7] mm/powerpc: Use generic VDSO remap and unmap functions
In-Reply-To: <e974b3a6-2a80-a416-7583-4b0644e8a613@linux.vnet.ibm.com>
References: <20161101171101.24704-1-cov@codeaurora.org> <20161101171101.24704-6-cov@codeaurora.org> <87oa1vn8lc.fsf@concordia.ellerman.id.au> <e974b3a6-2a80-a416-7583-4b0644e8a613@linux.vnet.ibm.com>
Date: Tue, 08 Nov 2016 10:51:56 +1100
Message-ID: <87shr2lug3.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Laurent Dufour <ldufour@linux.vnet.ibm.com>, Christopher Covington <cov@codeaurora.org>, criu@openvz.org, Will Deacon <will.deacon@arm.com>, linux-mm@kvack.org
Cc: Benjamin Herrenschmidt <benh@kernel.crashing.org>, Paul Mackerras <paulus@samba.org>, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

Laurent Dufour <ldufour@linux.vnet.ibm.com> writes:

> On 04/11/2016 05:59, Michael Ellerman wrote:
>> Christopher Covington <cov@codeaurora.org> writes:
>> 
>>> The PowerPC VDSO remap and unmap code was copied to a generic location,
>>> only modifying the variable name expected in mm->context (vdso instead of
>>> vdso_base) to match most other architectures. Having adopted this generic
>>> naming, drop the code in arch/powerpc and use the generic version.
>>>
>>> Signed-off-by: Christopher Covington <cov@codeaurora.org>
>>> ---
>>>  arch/powerpc/Kconfig                     |  1 +
>>>  arch/powerpc/include/asm/Kbuild          |  1 +
>>>  arch/powerpc/include/asm/mm-arch-hooks.h | 28 -------------------------
>>>  arch/powerpc/include/asm/mmu_context.h   | 35 +-------------------------------
>>>  4 files changed, 3 insertions(+), 62 deletions(-)
>>>  delete mode 100644 arch/powerpc/include/asm/mm-arch-hooks.h
>> 
>> This looks OK.
>> 
>> Have you tested it on powerpc? I could but I don't know how to actually
>> trigger these paths, I assume I need a CRIU setup?
>
> FWIW, tested on ppc64le using a sample test process moving its VDSO and
> then catching a signal on 4.9-rc4 and using CRIU on top of 4.8 with
> sightly changes to due minor upstream changes.
>
> Reviewed-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>
> Tested-by: Laurent Dufour <ldufour@linux.vnet.ibm.com>

Thanks, in that case:

Acked-by: Michael Ellerman <mpe@ellerman.id.au>

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
