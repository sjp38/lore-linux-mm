Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f70.google.com (mail-pl0-f70.google.com [209.85.160.70])
	by kanga.kvack.org (Postfix) with ESMTP id 202076B0003
	for <linux-mm@kvack.org>; Fri, 13 Apr 2018 15:15:43 -0400 (EDT)
Received: by mail-pl0-f70.google.com with SMTP id f4-v6so6316801plm.12
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 12:15:43 -0700 (PDT)
Received: from EUR01-HE1-obe.outbound.protection.outlook.com (mail-he1eur01on0100.outbound.protection.outlook.com. [104.47.0.100])
        by mx.google.com with ESMTPS id j1si287870pff.7.2018.04.13.12.15.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Fri, 13 Apr 2018 12:15:41 -0700 (PDT)
Subject: Re: [PATCH] kasan: add no_sanitize attribute for clang builds
References: <4ad725cc903f8534f8c8a60f0daade5e3d674f8d.1523554166.git.andreyknvl@google.com>
 <b849e2ff-3693-9546-5850-1ddcea23ee29@virtuozzo.com>
 <CAAeHK+y18zU_PAS5KB82PNqtvGNex+S0Jk3bWaE19=YjThaNow@mail.gmail.com>
From: Andrey Ryabinin <aryabinin@virtuozzo.com>
Message-ID: <c95bd92f-bef4-378a-55ed-04439c784e43@virtuozzo.com>
Date: Fri, 13 Apr 2018 22:16:30 +0300
MIME-Version: 1.0
In-Reply-To: <CAAeHK+y18zU_PAS5KB82PNqtvGNex+S0Jk3bWaE19=YjThaNow@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Language: en-US
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Konovalov <andreyknvl@google.com>
Cc: Alexander Potapenko <glider@google.com>, Dmitry Vyukov <dvyukov@google.com>, Andrew Morton <akpm@linux-foundation.org>, David Rientjes <rientjes@google.com>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@kernel.org>, David Woodhouse <dwmw@amazon.co.uk>, Will Deacon <will.deacon@arm.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Paul Lawrence <paullawrence@google.com>, Sandipan Das <sandipan@linux.vnet.ibm.com>, Kees Cook <keescook@chromium.org>, LKML <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>, Linux Memory Management List <linux-mm@kvack.org>, Kostya Serebryany <kcc@google.com>



On 04/13/2018 08:34 PM, Andrey Konovalov wrote:
> On Fri, Apr 13, 2018 at 5:31 PM, Andrey Ryabinin
> <aryabinin@virtuozzo.com> wrote:
>>
>>
>> On 04/12/2018 08:29 PM, Andrey Konovalov wrote:
>>> KASAN uses the __no_sanitize_address macro to disable instrumentation
>>> of particular functions. Right now it's defined only for GCC build,
>>> which causes false positives when clang is used.
>>>
>>> This patch adds a definition for clang.
>>>
>>> Note, that clang's revision 329612 or higher is required.
>>>
>>> Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
>>> ---
>>>  include/linux/compiler-clang.h | 5 +++++
>>>  1 file changed, 5 insertions(+)
>>>
>>> diff --git a/include/linux/compiler-clang.h b/include/linux/compiler-clang.h
>>> index ceb96ecab96e..5a1d8580febe 100644
>>> --- a/include/linux/compiler-clang.h
>>> +++ b/include/linux/compiler-clang.h
>>> @@ -25,6 +25,11 @@
>>>  #define __SANITIZE_ADDRESS__
>>>  #endif
>>>
>>> +#ifdef CONFIG_KASAN
>>
>> If, for whatever reason, developer decides to add __no_sanitize_address to some
>> generic function, guess what will happen next when he/she will try to build CONFIG_KASAN=n kernel?
> 
> It's defined to nothing in compiler-gcc.h and redefined in
> compiler-clang.h only if CONFIG_KASAN is enabled, so everything should
> be fine. Am I missing something?

No, It's was me missing something ;)
However, "#ifdef CONFIG_KASAN" seems to be redundant, I'd rather remove it.

Anyway:
	Acked-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
