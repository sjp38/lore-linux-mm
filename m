Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 92B556B0333
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:27:58 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id n66so92238396oib.6
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:27:58 -0700 (PDT)
Received: from mail-ot0-x244.google.com (mail-ot0-x244.google.com. [2607:f8b0:4003:c0f::244])
        by mx.google.com with ESMTPS id h130si586728oia.167.2017.03.22.04.27.57
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 04:27:57 -0700 (PDT)
Received: by mail-ot0-x244.google.com with SMTP id y88so2245921ota.1
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 04:27:57 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170322111022.85745-1-dvyukov@google.com>
References: <20170322111022.85745-1-dvyukov@google.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 22 Mar 2017 12:27:56 +0100
Message-ID: <CAK8P3a2pm2EsxOxxf7SsEObxcNFJP60JOY_78a19g2kD4pL6Rw@mail.gmail.com>
Subject: Re: [PATCH] asm-generic: fix compilation failure in cmpxchg_double()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Mark Rutland <mark.rutland@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>

On Wed, Mar 22, 2017 at 12:10 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Arnd reported that the new code leads to compilation failures
> with some versions of gcc. I've filed gcc issue 72873,
> but we need a kernel fix as well.
>
> Remove instrumentation from cmpxchg_double() for now.

Thanks, I also checked that fixes the build error for me.

       Arnd

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
