Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f172.google.com (mail-ig0-f172.google.com [209.85.213.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1444C6B0279
	for <linux-mm@kvack.org>; Wed, 22 Jul 2015 13:59:31 -0400 (EDT)
Received: by igr7 with SMTP id 7so74446494igr.0
        for <linux-mm@kvack.org>; Wed, 22 Jul 2015 10:59:30 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id c3si5465213pat.101.2015.07.22.10.54.31
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 22 Jul 2015 10:54:32 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRW00GV3HQRCG10@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Jul 2015 18:54:27 +0100 (BST)
Message-id: <55AFD8D0.9020308@samsung.com>
Date: Wed, 22 Jul 2015 20:54:24 +0300
From: Andrey Ryabinin <a.ryabinin@samsung.com>
MIME-version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
 <1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
 <CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
 <CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
 <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
 <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
 <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
 <55AE56DB.4040607@samsung.com>
 <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
In-reply-to: 
 <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/22/2015 12:27 AM, Linus Walleij wrote:
> On Tue, Jul 21, 2015 at 4:27 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> 
>> I used vexpress. Anyway, it doesn't matter now, since I have an update
>> with a lot of stuff fixed, and it works on hardware.
>> I still need to do some work on it and tomorrow, probably, I will share.
> 
> Ah awesome. I have a stash of ARM boards so I can test it on a
> range of hardware once you feel it's ready.
> 

So here is updated version:
	git://github.com/aryabinin/linux.git kasan/arm_v0_1

The code is still ugly in some places and it probably have some bugs.
Lightly tested on exynos 5410/5420.


> Sorry for pulling stuff out of your hands, people are excited about
> KASan ARM32 as it turns out.
> 
> Yours,
> Linus Walleij
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
