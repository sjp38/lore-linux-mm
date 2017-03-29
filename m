Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 472EE6B0390
	for <linux-mm@kvack.org>; Wed, 29 Mar 2017 04:21:38 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id y16so3396108vky.9
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:21:38 -0700 (PDT)
Received: from mail-vk0-x230.google.com (mail-vk0-x230.google.com. [2607:f8b0:400c:c05::230])
        by mx.google.com with ESMTPS id 104si532596uan.178.2017.03.29.01.21.37
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 29 Mar 2017 01:21:37 -0700 (PDT)
Received: by mail-vk0-x230.google.com with SMTP id s68so9131268vke.3
        for <linux-mm@kvack.org>; Wed, 29 Mar 2017 01:21:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328213513.GB12803@bombadil.infradead.org>
References: <cover.1490717337.git.dvyukov@google.com> <ffaaa56d5099d2926004f0290f73396d0bd842c8.1490717337.git.dvyukov@google.com>
 <20170328213513.GB12803@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Wed, 29 Mar 2017 10:21:16 +0200
Message-ID: <CACT4Y+bawF=f_VNoYzfqpwT7FV7+iYA0QW+4NXZCdSh=vDgcMg@mail.gmail.com>
Subject: Re: [PATCH 4/8] asm-generic: add atomic-instrumented.h
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 28, 2017 at 11:35 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Mar 28, 2017 at 06:15:41PM +0200, Dmitry Vyukov wrote:
>> The new header allows to wrap per-arch atomic operations
>> and add common functionality to all of them.
>
> Why a new header instead of putting this in linux/atomic.h?


Only a subset of archs include this header. If we pre-include it for
all arches without changing their atomic.h, we will break build. We of
course play some tricks with preprocessor.
It's also large enough to put into a separate header IMO.
Also a reasonable question: why put it into linux/atomic.h instead of
a new header? :)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
