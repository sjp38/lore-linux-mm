Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 0959D6B0038
	for <linux-mm@kvack.org>; Wed, 12 Aug 2015 05:30:40 -0400 (EDT)
Received: by wibhh20 with SMTP id hh20so19776384wib.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:30:39 -0700 (PDT)
Received: from mail-wi0-x234.google.com (mail-wi0-x234.google.com. [2a00:1450:400c:c05::234])
        by mx.google.com with ESMTPS id h3si9509780wjz.123.2015.08.12.02.30.38
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Aug 2015 02:30:38 -0700 (PDT)
Received: by wicne3 with SMTP id ne3so92471640wic.0
        for <linux-mm@kvack.org>; Wed, 12 Aug 2015 02:30:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20150811164010.GJ23307@e104818-lin.cambridge.arm.com>
References: <1439259499-13913-1-git-send-email-ryabinin.a.a@gmail.com>
	<1439259499-13913-3-git-send-email-ryabinin.a.a@gmail.com>
	<20150811154117.GH23307@e104818-lin.cambridge.arm.com>
	<55CA21E8.2060704@gmail.com>
	<20150811164010.GJ23307@e104818-lin.cambridge.arm.com>
Date: Wed, 12 Aug 2015 12:30:37 +0300
Message-ID: <CAPAsAGwDNpRBLAvyCSpR9ZO9tAmHx-XYjVDZPECeQkU0WOw5jg@mail.gmail.com>
Subject: Re: [PATCH v5 2/6] x86/kasan, mm: introduce generic kasan_populate_zero_shadow()
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Catalin Marinas <catalin.marinas@arm.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, Yury <yury.norov@gmail.com>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Linus Walleij <linus.walleij@linaro.org>, "x86@kernel.org" <x86@kernel.org>, Will Deacon <will.deacon@arm.com>, LKML <linux-kernel@vger.kernel.org>, Alexey Klimov <klimov.linux@gmail.com>, Ingo Molnar <mingo@redhat.com>, Alexander Potapenko <glider@google.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, David Keitel <dkeitel@codeaurora.org>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-arm-kernel@lists.infradead.org

2015-08-11 19:40 GMT+03:00 Catalin Marinas <catalin.marinas@arm.com>:
>
> Not sure how you plan to merge it though since there are x86
> dependencies. I could send the whole series via tip or the mm tree (and
> I guess it's pretty late for 4.3).

Via mm tree, I guess.
If this is too late for 4.3, then I'll update changelog and send v6
after 4.3-rc1 release.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
