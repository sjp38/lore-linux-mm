Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f181.google.com (mail-ob0-f181.google.com [209.85.214.181])
	by kanga.kvack.org (Postfix) with ESMTP id 521059003C7
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 17:27:57 -0400 (EDT)
Received: by obbop1 with SMTP id op1so123323936obb.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:27:57 -0700 (PDT)
Received: from mail-ob0-f179.google.com (mail-ob0-f179.google.com. [209.85.214.179])
        by mx.google.com with ESMTPS id u4si19744327oik.24.2015.07.21.14.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jul 2015 14:27:56 -0700 (PDT)
Received: by obdeg2 with SMTP id eg2so27546802obd.0
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 14:27:56 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <55AE56DB.4040607@samsung.com>
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>
	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>
	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>
	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>
	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>
	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>
	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
	<55AE56DB.4040607@samsung.com>
Date: Tue, 21 Jul 2015 23:27:56 +0200
Message-ID: <CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
From: Linus Walleij <linus.walleij@linaro.org>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <a.ryabinin@samsung.com>
Cc: Andrey Ryabinin <ryabinin.a.a@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Jul 21, 2015 at 4:27 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:

> I used vexpress. Anyway, it doesn't matter now, since I have an update
> with a lot of stuff fixed, and it works on hardware.
> I still need to do some work on it and tomorrow, probably, I will share.

Ah awesome. I have a stash of ARM boards so I can test it on a
range of hardware once you feel it's ready.

Sorry for pulling stuff out of your hands, people are excited about
KASan ARM32 as it turns out.

Yours,
Linus Walleij

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
