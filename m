Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f44.google.com (mail-oi0-f44.google.com [209.85.218.44])
	by kanga.kvack.org (Postfix) with ESMTP id 52F636B014C
	for <linux-mm@kvack.org>; Tue, 26 May 2015 16:28:01 -0400 (EDT)
Received: by oifu123 with SMTP id u123so47571755oif.1
        for <linux-mm@kvack.org>; Tue, 26 May 2015 13:28:01 -0700 (PDT)
Received: from mail-oi0-f54.google.com (mail-oi0-f54.google.com. [209.85.218.54])
        by mx.google.com with ESMTPS id b72si9434623oih.14.2015.05.26.13.28.00
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 26 May 2015 13:28:00 -0700 (PDT)
Received: by oiww2 with SMTP id w2so87200474oiw.0
        for <linux-mm@kvack.org>; Tue, 26 May 2015 13:28:00 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55648193.3030003@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkda3Pe9L14_iyKEfeCx1F3XJSLbz_OVHLxX0Lzy9Gt9t9Q@mail.gmail.com>
	<55647F57.8010008@samsung.com>
	<55648193.3030003@samsung.com>
Date: Tue, 26 May 2015 22:28:00 +0200
Message-ID: <CACRpkdZsVqCy4pqVyu0_5+6m8dKdoa=60DU8fo59WZ6ZyQXRPA@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, linux-mm@kvack.org

On Tue, May 26, 2015 at 4:22 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> On 05/26/2015 05:12 PM, Andrey Ryabinin wrote:
>> On 05/26/2015 04:35 PM, Linus Walleij wrote:
>>> I wonder were the problem lies, any hints where to start looking
>>> to fix this?
>>>
>>
>> I suspect that your compiler lack -fsantize=kernel-address support.
>> It seems that GCC 4.9.2 doesn't supports -fsanitize=address/kernel-address on aarch64.
>>
>
> In that case you should get something like this, during kernel build:
>         scripts/Makefile.kasan:17: Cannot use CONFIG_KASAN: -fsanitize=kernel-address is not supported by compiler

Aha yep that's it when I look closer...

I'm going back and rebuilding my compiler. May as well do a trunk
5.0 build and try to get KASAN_INLINE working while I'm at it.

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
