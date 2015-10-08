Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f170.google.com (mail-lb0-f170.google.com [209.85.217.170])
	by kanga.kvack.org (Postfix) with ESMTP id 827CE6B0038
	for <linux-mm@kvack.org>; Thu,  8 Oct 2015 07:23:10 -0400 (EDT)
Received: by lbcao8 with SMTP id ao8so43590887lbc.3
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 04:23:09 -0700 (PDT)
Received: from mail-lb0-x22e.google.com (mail-lb0-x22e.google.com. [2a00:1450:4010:c04::22e])
        by mx.google.com with ESMTPS id 94si29313107lfx.64.2015.10.08.04.23.08
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Oct 2015 04:23:09 -0700 (PDT)
Received: by lbwr8 with SMTP id r8so42804814lbw.2
        for <linux-mm@kvack.org>; Thu, 08 Oct 2015 04:23:08 -0700 (PDT)
Subject: Re: [PATCH v6 0/6] KASAN for arm64
References: <1442482692-6416-1-git-send-email-ryabinin.a.a@gmail.com>
 <20151007100411.GG3069@e104818-lin.cambridge.arm.com>
 <CAPAsAGxR-yqtmFeo65Xw_0RQyEy=mN1uG=GKtqoMLr_x_N0u5w@mail.gmail.com>
 <20151008111144.GC7275@leverpostej>
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Message-ID: <56165228.8060201@gmail.com>
Date: Thu, 8 Oct 2015 14:23:20 +0300
MIME-Version: 1.0
In-Reply-To: <20151008111144.GC7275@leverpostej>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mark Rutland <mark.rutland@arm.com>, Ard Biesheuvel <ard.biesheuvel@linaro.org>
Cc: Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, linux-arm-kernel@lists.infradead.org, Yury <yury.norov@gmail.com>, Alexey Klimov <klimov.linux@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Andrey Konovalov <andreyknvl@google.com>, Linus Walleij <linus.walleij@linaro.org>, LKML <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Mark Salter <msalter@redhat.com>, linux-efi@vger.kernel.org

On 10/08/2015 02:11 PM, Mark Rutland wrote:
> On Thu, Oct 08, 2015 at 01:36:09PM +0300, Andrey Ryabinin wrote:
>> 2015-10-07 13:04 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>>> On Thu, Sep 17, 2015 at 12:38:06PM +0300, Andrey Ryabinin wrote:
>>>> As usual patches available in git
>>>>       git://github.com/aryabinin/linux.git kasan/arm64v6
>>>>
>>>> Changes since v5:
>>>>  - Rebase on top of 4.3-rc1
>>>>  - Fixed EFI boot.
>>>>  - Updated Doc/features/KASAN.
>>>
>>> I tried to merge these patches (apart from the x86 one which is already
>>> merged) but it still doesn't boot on Juno as an EFI application.
>>>
>>
>> 4.3-rc1 was ok and 4.3-rc4 is not. Break caused by 0ce3cc008ec04
>> ("arm64/efi: Fix boot crash by not padding between EFI_MEMORY_RUNTIME
>> regions")
>> It introduced sort() call in efi_get_virtmap().
>> sort() is generic kernel function and it's instrumented, so we crash
>> when KASAN tries to access shadow in sort().
> 
> I believe this is solved by Ard's stub isolation series [1,2], which
> will build a stub-specific copy of sort() and various other functions
> (see the arm-deps in [2]).
> 
> So long as the stub is not built with ASAN, that should work.

Thanks, this should help, as we already build the stub without ASAN instrumentation.

> 
> Mark.
> 
> [1] http://lists.infradead.org/pipermail/linux-arm-kernel/2015-October/373807.html
> [2] http://lists.infradead.org/pipermail/linux-arm-kernel/2015-October/373808.html
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
