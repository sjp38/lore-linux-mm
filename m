Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ot0-f200.google.com (mail-ot0-f200.google.com [74.125.82.200])
	by kanga.kvack.org (Postfix) with ESMTP id 3047F6B03A8
	for <linux-mm@kvack.org>; Fri, 23 Jun 2017 04:23:22 -0400 (EDT)
Received: by mail-ot0-f200.google.com with SMTP id 63so26527730otc.5
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:23:22 -0700 (PDT)
Received: from mail-oi0-x233.google.com (mail-oi0-x233.google.com. [2607:f8b0:4003:c06::233])
        by mx.google.com with ESMTPS id p30si1385844otb.197.2017.06.23.01.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 23 Jun 2017 01:23:21 -0700 (PDT)
Received: by mail-oi0-x233.google.com with SMTP id c189so21859972oia.2
        for <linux-mm@kvack.org>; Fri, 23 Jun 2017 01:23:21 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170622141411.6af8091132e4416e3635b62e@linux-foundation.org>
References: <cover.1498140468.git.dvyukov@google.com> <ff85407a7476ac41bfbdd46a35a93b8f57fa4b1e.1498140838.git.dvyukov@google.com>
 <20170622141411.6af8091132e4416e3635b62e@linux-foundation.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 23 Jun 2017 10:23:00 +0200
Message-ID: <CACT4Y+YQchHWK+8jEo03dK21xM77pn0YePkjUTVny0-Cx8yYeg@mail.gmail.com>
Subject: Re: [PATCH v5 1/4] x86: switch atomic.h to use atomic-instrumented.h
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Will Deacon <will.deacon@arm.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, "x86@kernel.org" <x86@kernel.org>, LKML <linux-kernel@vger.kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Thu, Jun 22, 2017 at 11:14 PM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Thu, 22 Jun 2017 16:14:16 +0200 Dmitry Vyukov <dvyukov@google.com> wrote:
>
>> Add arch_ prefix to all atomic operations and include
>> <asm-generic/atomic-instrumented.h>. This will allow
>> to add KASAN instrumentation to all atomic ops.
>
> This gets a large number of (simple) rejects when applied to
> linux-next.  Can you please redo against -next?


This is based on tip/locking tree. Ingo already took a part of these
series. The plan is that he takes the rest, and this applies on
tip/locking without conflicts.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
