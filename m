Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f182.google.com (mail-lb0-f182.google.com [209.85.217.182])
	by kanga.kvack.org (Postfix) with ESMTP id B668B900021
	for <linux-mm@kvack.org>; Tue, 28 Oct 2014 23:28:26 -0400 (EDT)
Received: by mail-lb0-f182.google.com with SMTP id f15so1882889lbj.41
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 20:28:25 -0700 (PDT)
Received: from mail-la0-x22b.google.com (mail-la0-x22b.google.com. [2a00:1450:4010:c03::22b])
        by mx.google.com with ESMTPS id bf9si5206510lab.114.2014.10.28.20.28.24
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 28 Oct 2014 20:28:24 -0700 (PDT)
Received: by mail-la0-f43.google.com with SMTP id ge10so1806460lab.30
        for <linux-mm@kvack.org>; Tue, 28 Oct 2014 20:28:24 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <1414392371.8884.2.camel@perches.com>
References: <35FD53F367049845BC99AC72306C23D103E010D18254@CNBJMBX05.corpusers.net>
 <35FD53F367049845BC99AC72306C23D103E010D18257@CNBJMBX05.corpusers.net> <1414392371.8884.2.camel@perches.com>
From: Rob Herring <robherring2@gmail.com>
Date: Wed, 29 Oct 2014 11:28:04 +0800
Message-ID: <CAL_JsqJYBoG+nrr7R3UWz1wrZ--Xjw5X31RkpCrTWMJAePBgRg@mail.gmail.com>
Subject: Re: [RFC V2] arm/arm64:add CONFIG_HAVE_ARCH_BITREVERSE to support
 rbit instruction
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joe Perches <joe@perches.com>
Cc: "Wang, Yalin" <Yalin.Wang@sonymobile.com>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "akinobu.mita@gmail.com" <akinobu.mita@gmail.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On Mon, Oct 27, 2014 at 2:46 PM, Joe Perches <joe@perches.com> wrote:
> On Mon, 2014-10-27 at 14:37 +0800, Wang, Yalin wrote:
>> this change add CONFIG_HAVE_ARCH_BITREVERSE config option,
>> so that we can use arm/arm64 rbit instruction to do bitrev operation
>> by hardware.

I don't see the original patch in my inbox, so replying here.

>>
>> Signed-off-by: Yalin Wang <yalin.wang@sonymobile.com>
>> ---
>>  arch/arm/Kconfig                |  1 +
>>  arch/arm/include/asm/bitrev.h   | 21 +++++++++++++++++++++
>>  arch/arm64/Kconfig              |  1 +
>>  arch/arm64/include/asm/bitrev.h | 21 +++++++++++++++++++++
>>  include/linux/bitrev.h          |  9 +++++++++
>>  lib/Kconfig                     |  9 +++++++++
>>  lib/bitrev.c                    |  2 ++
>>  7 files changed, 64 insertions(+)
>>  create mode 100644 arch/arm/include/asm/bitrev.h
>>  create mode 100644 arch/arm64/include/asm/bitrev.h
>>
>> diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
>> index 89c4b5c..426cbcc 100644
>> --- a/arch/arm/Kconfig
>> +++ b/arch/arm/Kconfig
>> @@ -16,6 +16,7 @@ config ARM
>>       select DCACHE_WORD_ACCESS if HAVE_EFFICIENT_UNALIGNED_ACCESS
>>       select GENERIC_ALLOCATOR
>>       select GENERIC_ATOMIC64 if (CPU_V7M || CPU_V6 || !CPU_32v6K || !AEABI)
>> +     select HAVE_ARCH_BITREVERSE if (CPU_V7M || CPU_V7)
>>       select GENERIC_CLOCKEVENTS_BROADCAST if SMP
>>       select GENERIC_IDLE_POLL_SETUP
>>       select GENERIC_IRQ_PROBE

[...]

>> diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
>> index 9532f8d..263c28c 100644
>> --- a/arch/arm64/Kconfig
>> +++ b/arch/arm64/Kconfig
>> @@ -36,6 +36,7 @@ config ARM64
>>       select HARDIRQS_SW_RESEND
>>       select HAVE_ARCH_AUDITSYSCALL
>>       select HAVE_ARCH_JUMP_LABEL
>> +     select HAVE_ARCH_BITREVERSE
>>       select HAVE_ARCH_KGDB
>>       select HAVE_ARCH_TRACEHOOK
>>       select HAVE_BPF_JIT

The kconfig lists should be sorted.

Rob

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
