Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f199.google.com (mail-ot0-f199.google.com [74.125.82.199])
	by kanga.kvack.org (Postfix) with ESMTP id 3DBF86B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 10:13:02 -0400 (EDT)
Received: by mail-ot0-f199.google.com with SMTP id l49so201786584otc.5
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:13:02 -0700 (PDT)
Received: from mail-oi0-x242.google.com (mail-oi0-x242.google.com. [2607:f8b0:4003:c06::242])
        by mx.google.com with ESMTPS id q44si810767otq.141.2017.03.22.07.13.01
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 22 Mar 2017 07:13:01 -0700 (PDT)
Received: by mail-oi0-x242.google.com with SMTP id a94so8854561oic.0
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 07:13:01 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170322125740.85337-1-dvyukov@google.com>
References: <20170322125740.85337-1-dvyukov@google.com>
From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 22 Mar 2017 15:13:00 +0100
Message-ID: <CAK8P3a2NdyBRciYh9_N0wq8B_u0uS+3HwiSqKYe5ez5uZdwkiQ@mail.gmail.com>
Subject: Re: [PATCH v2] x86: s/READ_ONCE_NOCHECK/READ_ONCE/ in arch_atomic[64]_read()
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dmitry Vyukov <dvyukov@google.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Andrey Ryabinin <aryabinin@virtuozzo.com>, Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Linux-MM <linux-mm@kvack.org>, x86@kernel.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, kasan-dev <kasan-dev@googlegroups.com>

On Wed, Mar 22, 2017 at 1:57 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> Two problems was reported with READ_ONCE_NOCHECK in arch_atomic_read:
> 1. Andrey Ryabinin reported significant binary size increase
> (+400K of text). READ_ONCE_NOCHECK is intentionally compiled to
> non-inlined function call, and I counted 640 copies of it in my vmlinux.
> 2. Arnd Bergmann reported a new splat of too large frame sizes.
>
> A single inlined KASAN check is very cheap, a non-inlined function
> call with KASAN/KCOV instrumentation can easily be more expensive.
>
> Switch to READ_ONCE() in arch_atomic[64]_read().
>
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
> Reported-by: Arnd Bergmann <arnd@arndb.de>
> Reported-by: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Mark Rutland <mark.rutland@arm.com>
> Cc: Peter Zijlstra <peterz@infradead.org>
> Cc: Will Deacon <will.deacon@arm.com>
> Cc: Andrey Ryabinin <aryabinin@virtuozzo.com>
> Cc: Andrew Morton <akpm@linux-foundation.org>
> Cc: linux-mm@kvack.org
> Cc: x86@kernel.org
> Cc: linux-kernel@vger.kernel.org
> Cc: kasan-dev@googlegroups.com
> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>

Acked-by: Arnd Bergmann <arnd@arndb.de>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
