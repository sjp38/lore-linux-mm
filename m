Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f197.google.com (mail-io0-f197.google.com [209.85.223.197])
	by kanga.kvack.org (Postfix) with ESMTP id 93BAD6B03DC
	for <linux-mm@kvack.org>; Tue, 14 Feb 2017 19:45:16 -0500 (EST)
Received: by mail-io0-f197.google.com with SMTP id m98so138418915iod.2
        for <linux-mm@kvack.org>; Tue, 14 Feb 2017 16:45:16 -0800 (PST)
Received: from ozlabs.org (ozlabs.org. [2401:3900:2:1::2])
        by mx.google.com with ESMTPS id u22si2022546pfd.46.2017.02.14.16.45.15
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 14 Feb 2017 16:45:15 -0800 (PST)
From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH V2 2/2] powerpc/mm/autonuma: Switch ppc64 to its own implementeation of saved write
In-Reply-To: <87d1elufej.fsf@skywalker.in.ibm.com>
References: <1487050314-3892-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <1487050314-3892-3-git-send-email-aneesh.kumar@linux.vnet.ibm.com> <87y3x9kp8e.fsf@concordia.ellerman.id.au> <87d1elufej.fsf@skywalker.in.ibm.com>
Date: Wed, 15 Feb 2017 11:45:12 +1100
Message-ID: <87efz0l1t3.fsf@concordia.ellerman.id.au>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, akpm@linux-foundation.org, Rik van Riel <riel@surriel.com>, Mel Gorman <mgorman@techsingularity.net>, paulus@ozlabs.org, benh@kernel.crashing.org
Cc: linux-mm@kvack.org, linuxppc-dev@lists.ozlabs.org, linux-kernel@vger.kernel.org

"Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:

> Michael Ellerman <mpe@ellerman.id.au> writes:
>
>> "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com> writes:
>>> diff --git a/arch/powerpc/include/asm/book3s/64/mmu-hash.h b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>>> index 0735d5a8049f..8720a406bbbe 100644
>>> --- a/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>>> +++ b/arch/powerpc/include/asm/book3s/64/mmu-hash.h
>>> @@ -16,6 +16,9 @@
>>>  #include <asm/page.h>
>>>  #include <asm/bug.h>
>>>  
>>> +#ifndef __ASSEMBLY__
>>> +#include <linux/mmdebug.h>
>>> +#endif
>>
>> I assume that's for the VM_BUG_ON() you add below. But if so wouldn't
>> the #include be better placed in book3s/64/pgtable.h also?
>
> mmu-hash.h has got a hack that is explained below
>
> #ifndef __ASSEMBLY__
> #include <linux/mmdebug.h>
> #endif
> /*
>  * This is necessary to get the definition of PGTABLE_RANGE which we
>  * need for various slices related matters. Note that this isn't the
>  * complete pgtable.h but only a portion of it.
>  */
> #include <asm/book3s/64/pgtable.h>
>
> This is the only place where we do that book3s/64/pgtable.h include this
> way. Everybody should include asm/pgable.h which picks the righ version
> based on different config option.

I don't understand how that is related.

If you're adding a VM_BUG_ON() in book3s/64/pgtable.h, why isn't the
include of mmdebug.h in that file also?

cheers

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
