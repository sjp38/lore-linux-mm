Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f41.google.com (mail-pa0-f41.google.com [209.85.220.41])
	by kanga.kvack.org (Postfix) with ESMTP id 836226B0274
	for <linux-mm@kvack.org>; Tue, 21 Jul 2015 10:27:47 -0400 (EDT)
Received: by pabkd10 with SMTP id kd10so49238435pab.2
        for <linux-mm@kvack.org>; Tue, 21 Jul 2015 07:27:46 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id wk5si9719571pab.37.2015.07.21.07.27.44
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 21 Jul 2015 07:27:45 -0700 (PDT)
Received: from eucpsbgm1.samsung.com (unknown [203.254.199.244])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0NRU00I9TDI5LJ20@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Tue, 21 Jul 2015 15:27:41 +0100 (BST)
Message-id: <55AE56DB.4040607@samsung.com>
Date: Tue, 21 Jul 2015 17:27:39 +0300
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
In-reply-to: 
 <CACRpkdY2i2M27gP_fXawkFrC_GFgWaKr5rEn6d47refNPiEk=g@mail.gmail.com>
Content-type: text/plain; charset=utf-8
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Walleij <linus.walleij@linaro.org>, Andrey Ryabinin <ryabinin.a.a@gmail.com>
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Dmitry Vyukov <dvyukov@google.com>, Alexander Potapenko <glider@google.com>, David Keitel <dkeitel@codeaurora.org>, Arnd Bergmann <arnd@arndb.de>, Andrew Morton <akpm@linux-foundation.org>, Catalin Marinas <catalin.marinas@arm.com>, Will Deacon <will.deacon@arm.com>, "linux-arm-kernel@lists.infradead.org" <linux-arm-kernel@lists.infradead.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On 07/21/2015 01:36 PM, Linus Walleij wrote:
> On Wed, Jun 17, 2015 at 11:32 PM, Andrey Ryabinin
> <ryabinin.a.a@gmail.com> wrote:
>> 2015-06-13 18:25 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>>>
>>> On Fri, Jun 12, 2015 at 8:14 PM, Andrey Ryabinin <ryabinin.a.a@gmail.com> wrote:
>>>> 2015-06-11 16:39 GMT+03:00 Linus Walleij <linus.walleij@linaro.org>:
>>>>> On Fri, May 15, 2015 at 3:59 PM, Andrey Ryabinin <a.ryabinin@samsung.com> wrote:
>>>>>
>>>>>> This patch adds arch specific code for kernel address sanitizer
>>>>>> (see Documentation/kasan.txt).
>>>>>
>>>>> I looked closer at this again ... I am trying to get KASan up for
>>>>> ARM(32) with some tricks and hacks.
>>>>>
>>>>
>>>> I have some patches for that. They still need some polishing, but works for me.
>>>> I could share after I get back to office on Tuesday.
>>>
>>> OK! I'd be happy to test!
>>>
>>
>> I've pushed it here : git://github.com/aryabinin/linux.git kasan/arm_v0
>>
>> It far from ready. Firstly I've tried it only in qemu and it works.
> 
> Hm what QEMU model are you using? I tried to test it with Versatile
> (the most common) and it kinda boots and hangs:
> 

I used vexpress. Anyway, it doesn't matter now, since I have an update
with a lot of stuff fixed, and it works on hardware.
I still need to do some work on it and tomorrow, probably, I will share.




--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
