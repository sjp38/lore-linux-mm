Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f172.google.com (mail-pd0-f172.google.com [209.85.192.172])
	by kanga.kvack.org (Postfix) with ESMTP id 3AC399003C7
	for <linux-mm@kvack.org>; Mon, 27 Jul 2015 13:52:27 -0400 (EDT)
Received: by pdbbh15 with SMTP id bh15so55634037pdb.1
        for <linux-mm@kvack.org>; Mon, 27 Jul 2015 10:52:26 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id ld2si45649639pab.233.2015.07.27.10.52.25
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 27 Jul 2015 10:52:26 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NS500D9JQZ96K50@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 27 Jul 2015 18:52:21 +0100 (BST)
Message-id: <55B66FD3.6090201@samsung.com>
Date: Mon, 27 Jul 2015 20:52:19 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v4 1/7] x86/kasan: generate KASAN_SHADOW_OFFSET in Makefile
References: <1437756119-12817-1-git-send-email-a.ryabinin@samsung.com>
 <1437756119-12817-2-git-send-email-a.ryabinin@samsung.com>
 <20150727164034.GC350@e104818-lin.cambridge.arm.com>
In-reply-to: <20150727164034.GC350@e104818-lin.cambridge.arm.com>
Content-type: text/plain; charset=windows-1252
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, linux-mm@kvack.org, Linus Walleij <linus.walleij@linaro.org>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-kbuild@vger.kernel.org, David Keitel <dkeitel@codeaurora.org>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, Michal Marek <mmarek@suse.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Dmitry Vyukov <dvyukov@google.com>

On 07/27/2015 07:40 PM, Catalin Marinas wrote:
> On Fri, Jul 24, 2015 at 07:41:53PM +0300, Andrey Ryabinin wrote:
>> diff --git a/arch/x86/Kconfig b/arch/x86/Kconfig
>> index b3a1a5d..6d6dd6f 100644
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
>> @@ -255,11 +255,6 @@ config ARCH_SUPPORTS_OPTIMIZED_INLINING
>>  config ARCH_SUPPORTS_DEBUG_PAGEALLOC
>>  	def_bool y
>>  
>> -config KASAN_SHADOW_OFFSET
>> -	hex
>> -	depends on KASAN
>> -	default 0xdffffc0000000000
>> -
>>  config HAVE_INTEL_TXT
>>  	def_bool y
>>  	depends on INTEL_IOMMU && ACPI
>> diff --git a/arch/x86/Makefile b/arch/x86/Makefile
>> index 118e6de..c666989 100644
>> --- a/arch/x86/Makefile
>> +++ b/arch/x86/Makefile
>> @@ -39,6 +39,8 @@ ifdef CONFIG_X86_NEED_RELOCS
>>          LDFLAGS_vmlinux := --emit-relocs
>>  endif
>>  
>> +KASAN_SHADOW_OFFSET := 0xdffffc0000000000
> 
> To keep things simple for x86, can you not just define:
> 
> KASAN_SHADOW_OFFSET := $(CONFIG_KASAN_SHADOW_OFFSET)
> 
> or, even better, in scripts/Makefile.kasan:
> 
> KASAN_SHADOW_OFFSET ?= $(CONFIG_KASAN_SHADOW_OFFSET)
> 
> and set it under arch/arm64/Makefile only.
> 

Yes, this much better.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
