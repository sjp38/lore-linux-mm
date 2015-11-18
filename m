Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f173.google.com (mail-io0-f173.google.com [209.85.223.173])
	by kanga.kvack.org (Postfix) with ESMTP id A61E26B027E
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 10:52:37 -0500 (EST)
Received: by iofh3 with SMTP id h3so57817934iof.3
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:52:37 -0800 (PST)
Received: from mail-io0-x229.google.com (mail-io0-x229.google.com. [2607:f8b0:4001:c06::229])
        by mx.google.com with ESMTPS id l12si37982170igf.97.2015.11.18.07.52.37
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Nov 2015 07:52:37 -0800 (PST)
Received: by iouu10 with SMTP id u10so58740900iou.0
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 07:52:36 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <564C9DCC.50205@arm.com>
References: <1444665180-301-1-git-send-email-ryabinin.a.a@gmail.com>
	<20151013083432.GG6320@e104818-lin.cambridge.arm.com>
	<5649BAFD.6030005@arm.com>
	<5649F783.40109@gmail.com>
	<20151116165100.GE6556@e104818-lin.cambridge.arm.com>
	<564C8C47.1080904@gmail.com>
	<564C9DCC.50205@arm.com>
Date: Wed, 18 Nov 2015 16:52:36 +0100
Message-ID: <CAKv+Gu9hP3vaQUo62X5_15jRKwxA6P2d=wHtbVWMqm=FPNvNbg@mail.gmail.com>
Subject: Re: [PATCH v7 0/4] KASAN for arm64
From: Ard Biesheuvel <ard.biesheuvel@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Suzuki K. Poulose" <Suzuki.Poulose@arm.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, Catalin Marinas <catalin.marinas@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, Will Deacon <will.deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrey Konovalov <andreyknvl@google.com>, David Keitel <dkeitel@codeaurora.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

On 18 November 2015 at 16:48, Suzuki K. Poulose <Suzuki.Poulose@arm.com> wrote:
> On 18/11/15 14:33, Andrey Ryabinin wrote:
>
>> Is there any way to run 16K pages on emulated environment?
>> I've tried:
>>   - ARM V8 Foundation Platformr0p0 (platform build 9.4.59)
>
>
> Have you tried with the following option ?
>
> -C cluster<N>.has_16k_granule=1
>

That is only supported on FVP Base, not the Foundation model.

-- 
Ard.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
