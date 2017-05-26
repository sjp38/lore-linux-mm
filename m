Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id 8BC076B02C3
	for <linux-mm@kvack.org>; Fri, 26 May 2017 15:29:45 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id c71so16970442oig.1
        for <linux-mm@kvack.org>; Fri, 26 May 2017 12:29:45 -0700 (PDT)
Received: from mail-sor-f41.google.com (mail-sor-f41.google.com. [209.85.220.41])
        by mx.google.com with SMTPS id c53sor344803ote.197.2017.05.26.12.29.44
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 26 May 2017 12:29:44 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20170328213254.GA12803@bombadil.infradead.org>
References: <cover.1490717337.git.dvyukov@google.com> <aa139aea58a0c57961a81edc8b76edda75c6560d.1490717337.git.dvyukov@google.com>
 <20170328213254.GA12803@bombadil.infradead.org>
From: Dmitry Vyukov <dvyukov@google.com>
Date: Fri, 26 May 2017 21:29:23 +0200
Message-ID: <CACT4Y+ZDERPOOHy0Gdik1a48+2qJJw+yVN+_PU7XzZKPYb0fXg@mail.gmail.com>
Subject: Re: [PATCH 3/8] x86: use long long for 64-bit atomic ops
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Matthew Wilcox <willy@infradead.org>
Cc: Mark Rutland <mark.rutland@arm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Will Deacon <will.deacon@arm.com>, Andrey Ryabinin <aryabinin@virtuozzo.com>, kasan-dev <kasan-dev@googlegroups.com>, LKML <linux-kernel@vger.kernel.org>, "x86@kernel.org" <x86@kernel.org>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Tue, Mar 28, 2017 at 11:32 PM, Matthew Wilcox <willy@infradead.org> wrote:
> On Tue, Mar 28, 2017 at 06:15:40PM +0200, Dmitry Vyukov wrote:
>> @@ -193,12 +193,12 @@ static inline long atomic64_xchg(atomic64_t *v, long new)
>>   * @a: the amount to add to v...
>>   * @u: ...unless v is equal to u.
>>   *
>> - * Atomically adds @a to @v, so long as it was not @u.
>> + * Atomically adds @a to @v, so long long as it was not @u.
>>   * Returns the old value of @v.
>>   */
>
> That's a clbuttic mistake!
>
> https://www.google.com/search?q=clbuttic


Fixed in v2:
https://groups.google.com/forum/#!topic/kasan-dev/3PoGcuMku-w
Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
