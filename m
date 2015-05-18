Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f51.google.com (mail-pa0-f51.google.com [209.85.220.51])
	by kanga.kvack.org (Postfix) with ESMTP id C77446B0085
	for <linux-mm@kvack.org>; Mon, 18 May 2015 03:43:36 -0400 (EDT)
Received: by pacwv17 with SMTP id wv17so140961682pac.2
        for <linux-mm@kvack.org>; Mon, 18 May 2015 00:43:36 -0700 (PDT)
Received: from mailout1.w1.samsung.com (mailout1.w1.samsung.com. [210.118.77.11])
        by mx.google.com with ESMTPS id hx10si14734514pbc.131.2015.05.18.00.43.35
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 18 May 2015 00:43:35 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout1.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NOJ007AKC4J4S60@mailout1.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 18 May 2015 08:43:31 +0100 (BST)
Message-id: <55599821.40409@samsung.com>
Date: Mon, 18 May 2015 10:43:29 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 1/5] kasan, x86: move KASAN_SHADOW_OFFSET to the arch
 Kconfig
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-2-git-send-email-a.ryabinin@samsung.com>
 <1431775656.2341.10.camel@x220>
In-reply-to: <1431775656.2341.10.camel@x220>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul Bolle <pebolle@tiscali.nl>
Cc: linux-kernel@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, "maintainer:X86 ARCHITECTURE..." <x86@kernel.org>

On 05/16/2015 02:27 PM, Paul Bolle wrote:
> On Fri, 2015-05-15 at 16:59 +0300, Andrey Ryabinin wrote:
>> --- a/arch/x86/Kconfig
>> +++ b/arch/x86/Kconfig
> 
>> +config KASAN_SHADOW_OFFSET
>> +	hex
>> +	default 0xdffffc0000000000
> 
> This sets CONFIG_KASAN_SHADOW_OFFSET for _all_ X86 configurations,
> doesn't it?
> 

Right.

>> --- a/lib/Kconfig.kasan
>> +++ b/lib/Kconfig.kasan
>  
>> -config KASAN_SHADOW_OFFSET
>> -	hex
>> -	default 0xdffffc0000000000 if X86_64
> 
> While here it used to depend, at least, on HAVE_ARCH_KASAN. But grepping
> the tree shows the two places where CONFIG_KASAN_SHADOW_OFFSET is
> currently used are guarded by #ifdef CONFIG_KASAN. So perhaps the
> default line should actually read
> 	default 0xdffffc0000000000 if KASAN
> 
> after the move. Would that work?
> 

Yes, but I would rather add "depends on KASAN".

> 
> Paul Bolle
> 
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
