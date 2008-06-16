Received: by ti-out-0910.google.com with SMTP id j3so1535919tid.8
        for <linux-mm@kvack.org>; Mon, 16 Jun 2008 01:08:59 -0700 (PDT)
Message-ID: <a8e1da0806160108x3de46eafp545275eb9dfd4f98@mail.gmail.com>
Date: Mon, 16 Jun 2008 16:08:59 +0800
From: "Dave Young" <hidave.darkstar@gmail.com>
Subject: Re: [PATCH] kernel parameter vmalloc size fix
In-Reply-To: <20080616080131.GC25632@elte.hu>
MIME-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20080616042528.GA3003@darkstar.te-china.tietoenator.com>
	 <20080616080131.GC25632@elte.hu>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, hpa@zytor.com, the arch/x86 maintainers <x86@kernel.org>
List-ID: <linux-mm.kvack.org>

On Mon, Jun 16, 2008 at 4:01 PM, Ingo Molnar <mingo@elte.hu> wrote:
>
> * Dave Young <hidave.darkstar@gmail.com> wrote:
>
>> booting kernel with vmalloc=[any size<=16m] will oops.
>>
>> It's due to the vm area hole.
>>
>> In include/asm-x86/pgtable_32.h:
>> #define VMALLOC_OFFSET        (8 * 1024 * 1024)
>> #define VMALLOC_START (((unsigned long)high_memory + 2 * VMALLOC_OFFSET - 1) \
>>                        & ~(VMALLOC_OFFSET - 1))
>>
>> BUG_ON in arch/x86/mm/init_32.c will be triggered:
>> BUG_ON((unsigned long)high_memory             > VMALLOC_START);
>>
>> Fixed by return -EINVAL for invalid parameter
>
> hm. Why dont we instead add the size of the hole to the
> __VMALLOC_RESERVE value instead? There's nothing inherently bad about
> using vmalloc=16m. The VM area hole is really a kernel-internal
> abstraction that should not be visible in the usage of the parameter.

Good suggestion, thanks. I will rewrite the patch and send.

-- 
Regards
dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
