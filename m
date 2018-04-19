Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 377986B0005
	for <linux-mm@kvack.org>; Thu, 19 Apr 2018 02:20:56 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id 35-v6so2371914pla.18
        for <linux-mm@kvack.org>; Wed, 18 Apr 2018 23:20:56 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id y127sor751028pgy.417.2018.04.18.23.20.55
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Apr 2018 23:20:55 -0700 (PDT)
Date: Thu, 19 Apr 2018 15:20:50 +0900
From: Sergey Senozhatsky <sergey.senozhatsky.work@gmail.com>
Subject: Re: [console_unlock] BUG: KASAN: use-after-scope in
 console_unlock+0x9cd/0xd10
Message-ID: <20180419062050.GA8683@jagdpanzerIV>
References: <20180419021757.66xxs5fgvlrusiup@wfg-t540p.sh.intel.com>
 <CACT4Y+bmYk_A4NcOhCeHcG4t5_c=Q1fmQOPxHLtC8G0hLrxSLA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACT4Y+bmYk_A4NcOhCeHcG4t5_c=Q1fmQOPxHLtC8G0hLrxSLA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Fengguang Wu <fengguang.wu@intel.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Pavel Tatashin <pasha.tatashin@oracle.com>, Petr Mladek <pmladek@suse.com>, Sergey Senozhatsky <sergey.senozhatsky@gmail.com>, Steven Rostedt <rostedt@goodmis.org>, Linus Torvalds <torvalds@linux-foundation.org>, Nicolas Pitre <nicolas.pitre@linaro.org>, Nikitas Angelinas <nikitas.angelinas@gmail.com>, Matt Redfearn <matt.redfearn@mips.com>, LKML <linux-kernel@vger.kernel.org>, LKP <lkp@01.org>, Steven Sistare <steven.sistare@oracle.com>, Daniel Jordan <daniel.m.jordan@oracle.com>, Bob Picco <bob.picco@oracle.com>, Linux Memory Management List <linux-mm@kvack.org>, kasan-dev <kasan-dev@googlegroups.com>

On (04/19/18 08:04), Dmitry Vyukov wrote:
[..]
> We could also make them mutually exclusive in config to prevent people
> from hitting these false positives again and again.

Let's do it. Ard and Kees agreed on making them mutually exclusive [1][2].
Dmitry, could send out a patch?

[1] lkml.kernel.org/r/CAKv+Gu8HN-t2om8sCfjxCWbsgSir54fZw222dsed0Xwqph2aNg@mail.gmail.com
[2] lkml.kernel.org/r/CAGXu5j+mcfo4aB3PM1We6O62bFBJcMFX-9obJE4jFU1Dp=gNwg@mail.gmail.com

	-ss
