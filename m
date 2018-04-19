Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f69.google.com (mail-pl0-f69.google.com [209.85.160.69])
	by kanga.kvack.org (Postfix) with ESMTP id E11FA6B0003
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 05:50:41 -0400 (EDT)
Received: by mail-pl0-f69.google.com with SMTP id x5-v6so2684004pln.21
        for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:50:41 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id a7-v6sor1178442plp.27.2018.04.19.02.50.40
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 19 Apr 2018 02:50:41 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180419065531.l6kblbziddplgcwi@wfg-t540p.sh.intel.com>
References: <20180419021757.66xxs5fgvlrusiup@wfg-t540p.sh.intel.com>
 <CACT4Y+bmYk_A4NcOhCeHcG4t5_c=Q1fmQOPxHLtC8G0hLrxSLA@mail.gmail.com>
 <20180419062050.GA8683@jagdpanzerIV> <20180419065531.l6kblbziddplgcwi@wfg-t540p.sh.intel.com>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Thu, 19 Apr 2018 11:50:20 +0200
Message-ID: <CACT4Y+ZL_xY-HJwgU+XQ-onqe+coxbNGOBno6HrPHwYuPdHRFA@mail.gmail.com>
Subject: Re: [console_unlock] BUG: KASAN: use-after-scope in console_unlock+0x9cd/0xd10
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Fengguang Wu <fengguang.wu@intel.com>
Cc: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Nikitas Angelinas <nikitas.angelinas@gmail.com>, Matt Redfearn <matt.redfearn@mips.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On Thu, Apr 19, 2018 at 8:55 AM, Fengguang Wu <fengguang.wu@intel.com> wrote:
> On Thu, Apr 19, 2018 at 03:20:50PM +0900, Sergey Senozhatsky wrote:
>>
>> On (04/19/18 08:04), Dmitry Vyukov wrote:
>> [..]
>>>
>>> We could also make them mutually exclusive in config to prevent people
>>> from hitting these false positives again and again.
>>
>>
>> Let's do it. Ard and Kees agreed on making them mutually exclusive [1][2].
>> Dmitry, could send out a patch?
>>
>> [1]
>> lkml.kernel.org/r/CAKv+Gu8HN-t2om8sCfjxCWbsgSir54fZw222dsed0Xwqph2aNg@mail.gmail.com
>> [2]
>> lkml.kernel.org/r/CAGXu5j+mcfo4aB3PM1We6O62bFBJcMFX-9obJE4jFU1Dp=gNwg@mail.gmail.com
>
>
> That'd be great, thank you very much!


Just mailed "KASAN: prohibit KASAN+STRUCTLEAK combination":
https://groups.google.com/d/msg/kasan-dev/Y1TEh7ZlHTQ/wR36C8uMCgAJ
