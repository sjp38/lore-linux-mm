Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 3E5C16B025E
	for <linux-mm@kvack.org>; Thu,  1 Dec 2016 14:10:43 -0500 (EST)
Received: by mail-qk0-f198.google.com with SMTP id m67so187272603qkf.0
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 11:10:43 -0800 (PST)
Received: from mail-qt0-f178.google.com (mail-qt0-f178.google.com. [209.85.216.178])
        by mx.google.com with ESMTPS id d13si867561qte.229.2016.12.01.11.10.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Dec 2016 11:10:42 -0800 (PST)
Received: by mail-qt0-f178.google.com with SMTP id n6so230629450qtd.1
        for <linux-mm@kvack.org>; Thu, 01 Dec 2016 11:10:42 -0800 (PST)
Subject: Re: [PATCHv4 08/10] mm/kasan: Switch to using __pa_symbol and
 lm_alias
References: <1480445729-27130-1-git-send-email-labbott@redhat.com>
 <1480445729-27130-9-git-send-email-labbott@redhat.com>
 <2f3ac043-c4cc-5c5a-8ac7-1396b6bb193f@virtuozzo.com>
From: Laura Abbott <labbott@redhat.com>
Message-ID: <9dc192b3-a3bd-303a-1b65-00a735a38c74@redhat.com>
Date: Thu, 1 Dec 2016 11:10:35 -0800
MIME-Version: 1.0
In-Reply-To: <2f3ac043-c4cc-5c5a-8ac7-1396b6bb193f@virtuozzo.com>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>, Will Deacon <will.deacon@arm.com>, Catalin Marinas <catalin.marinas@arm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, "H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Marek Szyprowski <m.szyprowski@samsung.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, linux-arm-kernel@lists.infradead.org, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, kasan-dev@googlegroups.com

On 12/01/2016 03:36 AM, Andrey Ryabinin wrote:
> On 11/29/2016 09:55 PM, Laura Abbott wrote:
>> __pa_symbol is the correct API to find the physical address of symbols.
>> Switch to it to allow for debugging APIs to work correctly.
> 
> But __pa() is correct for symbols. I see how __pa_symbol() might be a little
> faster than __pa(), but there is nothing wrong in using __pa() on symbols.
> 
>> Other
>> functions such as p*d_populate may call __pa internally. Ensure that the
>> address passed is in the linear region by calling lm_alias.
> 
> Why it should be linear mapping address? __pa() translates kernel image address just fine.
> This lm_alias() only obfuscates source code. Generated code is probably worse too.
> 
> 

This is part of adding CONFIG_DEBUG_VIRTUAL for arm64. We want to
differentiate between __pa and __pa_symbol to enforce stronger
virtual checks and have __pa only be for linear map addresses.

Thanks,
Laura

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
