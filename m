Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f41.google.com (mail-la0-f41.google.com [209.85.215.41])
	by kanga.kvack.org (Postfix) with ESMTP id EB35F6B0038
	for <linux-mm@kvack.org>; Mon, 24 Aug 2015 12:16:54 -0400 (EDT)
Received: by labgv11 with SMTP id gv11so13144925lab.2
        for <linux-mm@kvack.org>; Mon, 24 Aug 2015 09:16:54 -0700 (PDT)
Received: from eu-smtp-delivery-143.mimecast.com (eu-smtp-delivery-143.mimecast.com. [146.101.78.143])
        by mx.google.com with ESMTPS id pk1si13453088lac.126.2015.08.24.09.16.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Mon, 24 Aug 2015 09:16:53 -0700 (PDT)
Message-ID: <55DB4372.5010406@arm.com>
Date: Mon, 24 Aug 2015 17:16:50 +0100
From: Vladimir Murzin <vladimir.murzin@arm.com>
MIME-Version: 1.0
Subject: Re: [PATCH v2 5/5] arm64: add KASan support
References: <1431698344-28054-1-git-send-email-a.ryabinin@samsung.com>	<1431698344-28054-6-git-send-email-a.ryabinin@samsung.com>	<CACRpkdaRJJjCXR=vK1M2YhR26JZfGoBB+jcqz8r2MhERfxRzqA@mail.gmail.com>	<CAPAsAGy-r8Z2N09wKV+e0kLfbwxd-eWK6N5Xajsnqq9jfyWqcQ@mail.gmail.com>	<CACRpkdZmHLMxosLXjyOPdkavo=UNzmTcHOLF5vV4cS1ULfbq6A@mail.gmail.com>	<CAPAsAGw-iawTpjJh66rQN5fqBFT6UBZCcv2eKx7JTqCXzhzpsw@mail.gmail.com>	<CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>	<55AE56DB.4040607@samsung.com>	<CACRpkdYaqK8upK-3b01JbO_y+sHnk4-Hm1MfvjSy0tKUkFREtQ@mail.gmail.com>	<20150824131557.GB7557@n2100.arm.linux.org.uk>	<CACRpkdYwpucRiXM05y00RQY=gKv8W6YjCNspYFRMGaM605cU0w@mail.gmail.com>	<CAPAsAGwji7FpUJK9O=FWYN15-rJkYMQyOt9W9ncdY9uLybxkiA@mail.gmail.com>	<55DB3BD3.7030202@arm.com> <CAPAsAGyg_oUvUrfSSQccVMcGtY_bwR8n6tf3tFsnh43YT6-b4w@mail.gmail.com>
In-Reply-To: <CAPAsAGyg_oUvUrfSSQccVMcGtY_bwR8n6tf3tFsnh43YT6-b4w@mail.gmail.com>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: Linus Walleij <linus.walleij@linaro.org>, Russell King - ARM Linux <linux@arm.linux.org.uk>, Arnd Bergmann <arnd@arndb.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>, Catalin Marinas <Catalin.Marinas@arm.com>, Will Deacon <Will.Deacon@arm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, David Keitel <dkeitel@codeaurora.org>, Alexander Potapenko <glider@google.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, Andrew Morton <akpm@linux-foundation.org>, Dmitry Vyukov <dvyukov@google.com>

On 24/08/15 17:00, Andrey Ryabinin wrote:
> 2015-08-24 18:44 GMT+03:00 Vladimir Murzin <vladimir.murzin@arm.com>:
>>
>> Another option would be having "sparse" shadow memory based on page
>> extension. I did play with that some time ago based on ideas from
>> original v1 KASan support for x86/arm - it is how 614be38 "irqchip:
>> gic-v3: Fix out of bounds access to cpu_logical_map" was caught.
>> It doesn't require any VA reservations, only some contiguous memory for
>> the page_ext itself, which serves as indirection level for the 0-order
>> shadow pages.
>=20
> We won't be able to use inline instrumentation (I could live with that),
> and most importantly, we won't be able to use stack instrumentation.
> GCC needs to know shadow address for inline and/or stack instrumentation
> to generate correct code.

It's definitely a trade-off ;)

Just for my understanding does that stack instrumentation is controlled
via -asan-stack?

Thanks
Vladimir

>=20
>> In theory such design can be reused by others 32-bit arches and, I
>> think, nommu too. Additionally, the shadow pages might be movable with
>> help of driver-page migration patch series [1].
>> The cost is obvious - performance drop, although I didn't bother
>> measuring it.
>>
>> [1] https://lwn.net/Articles/650917/
>>
>> Cheers
>> Vladimir
>>
>=20

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
