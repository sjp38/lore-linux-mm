Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id EED446B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:55:39 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id 203so2268560pfz.19
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 23:55:39 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id s2si2692328pfb.39.2018.04.18.23.55.38
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 18 Apr 2018 23:55:39 -0700 (PDT)
Date: Thu, 19 Apr 2018 14:55:31 +0800
From: Fengguang Wu <fengguang.wu@intel.com>
Subject: Re: [console_unlock] BUG: KASAN: use-after-scope in
 console_unlock+0x9cd/0xd10
Message-ID: <20180419065531.l6kblbziddplgcwi@wfg-t540p.sh.intel.com>
References: <20180419021757.66xxs5fgvlrusiup@wfg-t540p.sh.intel.com>
 <CACT4Y+bmYk_A4NcOhCeHcG4t5_c=Q1fmQOPxHLtC8G0hLrxSLA@mail.gmail.com>
 <20180419062050.GA8683@jagdpanzerIV>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Disposition: inline
In-Reply-To: <20180419062050.GA8683@jagdpanzerIV>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Nikitas Angelinas <nikitas.angelinas@gmail.com>, Matt Redfearn <matt.redfearn@mips.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On Thu, Apr 19, 2018 at 03:20:50PM +0900, Sergey Senozhatsky wrote:
>On (04/19/18 08:04), Dmitry Vyukov wrote:
>[..]
>> We could also make them mutually exclusive in config to prevent people
>> from hitting these false positives again and again.
>
>Let's do it. Ard and Kees agreed on making them mutually exclusive [1][2].
>Dmitry, could send out a patch?
>
>[1] lkml.kernel.org/r/CAKv+Gu8HN-t2om8sCfjxCWbsgSir54fZw222dsed0Xwqph2aNg@mail.gmail.com
>[2] lkml.kernel.org/r/CAGXu5j+mcfo4aB3PM1We6O62bFBJcMFX-9obJE4jFU1Dp=gNwg@mail.gmail.com

That'd be great, thank you very much!

Cheers,
Fengguang
