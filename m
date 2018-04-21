Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f72.google.com (mail-vk0-f72.google.com [209.85.213.72])
	by kanga.kvack.org (Postfix) with ESMTP id 4B82C6B0008
	for <linux-mm@kvack.org>; Sat, 21 Apr 2018 17:13:32 -0400 (EDT)
Received: by mail-vk0-f72.google.com with SMTP id v145so8122260vkv.17
        for <linux-mm@kvack.org>; Sat, 21 Apr 2018 14:13:32 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id b4sor3480299uab.103.2018.04.21.14.13.31
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sat, 21 Apr 2018 14:13:31 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180421210629.GA44181@big-sky.restechservices.net>
References: <20180419172451.104700-1-dvyukov@google.com> <CAGXu5jK0fWnyQUYP3H5e8hP-6QbtmeC102a-2Mab4CSqj4bpgg@mail.gmail.com>
 <20180420053329.GA37680@big-sky.local> <CACT4Y+ZZZvHDbiCXXWNVzACU25QZT0j-TbpMpSetuUQFb8Km=Q@mail.gmail.com>
 <20180421210629.GA44181@big-sky.restechservices.net>
From: Kees Cook <keescook@google.com>
Date: Sat, 21 Apr 2018 14:13:30 -0700
Message-ID: <CAGXu5j+CnH4+6GQ4jsv=4ZZTYgh960QsV69iDpXr56FABzFE_w@mail.gmail.com>
Subject: Re: [PATCH v2] KASAN: prohibit KASAN+STRUCTLEAK combination
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Linux-MM <linux-mm@kvack.org>, Andrew Morton <akpm@linux-foundation.org>, kasan-dev <kasan-dev@googlegroups.com>, Fengguang Wu <fengguang.wu@intel.com>, Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>

On Sat, Apr 21, 2018 at 2:06 PM, Dennis Zhou <dennisszhou@gmail.com> wrote:
> Hi,
>
> On Fri, Apr 20, 2018 at 07:56:56AM +0200, Dmitry Vyukov wrote:
>> As a sanity check, I would count number of zeroing inserted by the
>> plugin it both cases and ensure that now it does not insert order of
>> magnitude more/less. It's easy with function calls (count them in
>> objdump output), not sure what's the easiest way to do it for inline
>> instrumentation. We could insert printf into the pass itself, but it
>> if runs before inlining and other optimization, it's not the final
>> number.
>
> I modified the structleak_plugin to count the number of initializations
> and output if the function was an inline function or not. The aggregated
> values are below.
>
> declared inline       no       yes
> ----------------------------------
> early_optimizations:  12168   7114
> *all_optimizations:   12554     13
>
> These numbers seem appropriate. The structleak initializes in declared
> inline functions are redundant.

Does this mean we end up with redundant initializers, or are they
optimized away in later passes?

-Kees

-- 
Kees Cook
Pixel Security
