Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5200C6B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 13:25:47 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id h9so2720151pfn.22
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 10:25:47 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id 125sor1041812pfc.52.2018.04.19.10.25.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 10:25:46 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <d405534b-6d18-715a-85b9-7fc4305d75d3@virtuozzo.com>
References: <20180419094847.56737-1-dvyukov@google.com> <d405534b-6d18-715a-85b9-7fc4305d75d3@virtuozzo.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 19 Apr 2018 19:25:25 +0200
Message-ID: <CACT4Y+atCQR6P1-iNuOmEhtw8KD3fSbxjRguPU43nPOQWYX+mQ@mail.gmail.com>
Subject: Re: [PATCH] KASAN: prohibit KASAN+STRUCTLEAK combination
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrey Ryabinin <aryabinin@virtuozzo.com>
Cc: Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Kees Cook <keescook@google.com>

On Thu, Apr 19, 2018 at 7:21 PM, Andrey Ryabinin
<aryabinin@virtuozzo.com> wrote:
>
>
> On 04/19/2018 12:48 PM, Dmitry Vyukov wrote:
>
>> --- a/arch/Kconfig
>> +++ b/arch/Kconfig
>> @@ -464,6 +464,10 @@ config GCC_PLUGIN_LATENT_ENTROPY
>>  config GCC_PLUGIN_STRUCTLEAK
>>       bool "Force initialization of variables containing userspace addresses"
>>       depends on GCC_PLUGINS
>> +     # Currently STRUCTLEAK inserts initialization out of live scope of
>> +     # variables from KASAN point of view. This leads to KASAN false
>> +     # positive reports. Prohibit this combination for now.
>> +     depends on !KASAN
>                     KASAN_EXTRA

Remailed, thanks.
