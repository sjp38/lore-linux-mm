Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B8B696B0074
	for <linux-mm@kvack.org>; Wed, 17 Jun 2015 17:32:06 -0400 (EDT)
Received: by labbc20 with SMTP id bc20so42211613lab.1
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 14:32:06 -0700 (PDT)
Received: from mail-lb0-x22d.google.com (mail-lb0-x22d.google.com. [2a00:1450:4010:c04::22d])
        by mx.google.com with ESMTPS id o7si4688043lao.73.2015.06.17.14.32.04
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 17 Jun 2015 14:32:05 -0700 (PDT)
Received: by lblr1 with SMTP id r1so40439933lbl.0
        for <linux-mm@kvack.org>; Wed, 17 Jun 2015 14:32:04 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
Date: Thu, 18 Jun 2015 00:32:04 +0300
Message-ID: <CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>
Cc: Andrey Ryabinin <a.ryabinin@samsung.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

2015-06-13 18:25 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>
> On Fri, Jun 12, 2015 at 8:14 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
> > 2015-06-11 16:39 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
> >> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
> >>
> >>> This patch adds arch specific code for kernel address sanitizer
> >>> (see Documentation/kasan.txt).
> >>
> >> I looked closer at this again ... I am trying to get KASan up for
> >> ARM(32) with some tricks and hacks.
> >>
> >
> > I have some patches for that. They still need some polishing, but works for me.
> > I could share after I get back to office on Tuesday.
>
> OK! I'd be happy to test!
>

I've pushed it here : git://github.com/aryabinin/linux.git kasan/arm_v0

It far from ready. Firstly I've tried it only in qemu and it works.
Today, I've tried to run it on bare metal (exynos5420), but it hangs
somewhere after early_irq_init().
So, it probably doesn't  worth for trying/testing yet.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
