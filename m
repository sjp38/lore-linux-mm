Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f176.google.com (mail-wi0-f176.google.com [209.85.212.176])
	by kanga.kvack.org (Postfix) with ESMTP id 447096B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 08:19:06 -0400 (EDT)
Received: by wicne3 with SMTP id ne3so215745873wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:19:05 -0700 (PDT)
Received: from mail-wi0-x22f.google.com (mail-wi0-x22f.google.com. [2a00:1450:400c:c05::22f])
        by mx.google.com with ESMTPS id pi9si10237935wic.102.2015.08.12.05.19.03
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 05:19:04 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so215744591wic.1
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:19:03 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150812093701.GH22485@arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
	<1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
	<20150811154117.GH23307@e104818-lin.cambridge.arm.com>
	<55CA21E8.2060704@gmail.com>
	<20150811164010.GJ23307@e104818-lin.cambridge.arm.com>
	<CAPAsAGwDNpRBLAvyCSpR9ZO9tAmHx-XYjVDZPECeQkU0WOw5jg@mail.gmail.com>
	<20150812093701.GH22485@arm.com>
Date: Wed, 12 Aug 2015 15:19:03 +0300
Message-ID: <CAPAsAGwnhnqJCh=sc97-=qrYHNQnDSjVR-xGertoMiNWHDbhrw@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, "x86@kernel.org" <x86@kernel.org>, Ingo Molnar <mingo@redhat.com>, Thomas Gleixner <tglx@linutronix.de>
Cc: Catalin Marinas <Catalin.Marinas@arm.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>

2015-08-12 12:37 GMT+03:00 Will Deacon <will.deacon@arm.com>:
> On Wed, Aug 12, 2015 at 10:30:37AM +0100, Andrey Ryabinin wrote:
>> 2015-08-11 19:40 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>> >
>> > Not sure how you plan to merge it though since there are x86
>> > dependencies. I could send the whole series via tip or the mm tree (and
>> > I guess it's pretty late for 4.3).
>>
>> Via mm tree, I guess.
>> If this is too late for 4.3, then I'll update changelog and send v6
>> after 4.3-rc1 release.
>
> That's probably the best bet, as I suspect we'll get some non-trivial
> conflicts with the arm64 tree at this stage.
>
> Will

Or, if x86 maintainers are agree to take first 2 patches in 4.3,
the rest of the series could go into arm64 tree later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
