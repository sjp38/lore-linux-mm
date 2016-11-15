Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f200.google.com (mail-ua0-f200.google.com [209.85.217.200])
	by kanga.kvack.org (Postfix) with ESMTP id DCFE26B027C
	for <linux-mm@kvack.org>; Tue, 15 Nov 2016 08:35:53 -0500 (EST)
Received: by mail-ua0-f200.google.com with SMTP id 23so96826562uat.4
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 05:35:53 -0800 (PST)
Received: from mail-vk0-x241.google.com (mail-vk0-x241.google.com. [2607:f8b0:400c:c05::241])
        by mx.google.com with ESMTPS id d25si3797432uab.170.2016.11.15.05.35.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 15 Nov 2016 05:35:53 -0800 (PST)
Received: by mail-vk0-x241.google.com with SMTP id x186so9052565vkd.2
        for <linux-mm@kvack.org>; Tue, 15 Nov 2016 05:35:52 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <20161114163326.b5e991b77745bed6db221bfe@linux-foundation.org>
References: <20161111140207.1a5d89af4e0b37e9d23dcd36@gmail.com> <20161114163326.b5e991b77745bed6db221bfe@linux-foundation.org>
From: Vitaly Wool <vitalywool@gmail.com>
Date: Tue, 15 Nov 2016 14:35:52 +0100
Message-ID: <CAMJBoFOf_b8SxFqen-N=CVqp82s5KxV1ODvu74et7PQ6i__XFg@mail.gmail.com>
Subject: Re: [PATCH] z3fold: discourage use of pages that weren't compacted
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Linux-MM <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Dan Streetman <ddstreet@ieee.org>

On Tue, Nov 15, 2016 at 1:33 AM, Andrew Morton
<akpm@linux-foundation.org> wrote:
> On Fri, 11 Nov 2016 14:02:07 +0100 Vitaly Wool <vitalywool@gmail.com> wrote:
>
>> If a z3fold page couldn't be compacted, we don't want it to be
>> used for next object allocation in the first place. It makes more
>> sense to add it to the end of the relevant unbuddied list. If that
>> page gets compacted later, it will be added to the beginning of
>> the list then.
>>
>> This simple idea gives 5-7% improvement in randrw fio tests and
>> about 10% improvement in fio sequential read/write.
>
> This patch appears to require "z3fold: use per-page spinlock", and
> "z3fold: use per-page spinlock" doesn't apply properly.
>
> So things are in a bit of a mess.

Yep, sorry about that.

> I presently have
>
> z3fold-limit-first_num-to-the-actual-range-of-possible-buddy-indexes.patch
> z3fold-make-pages_nr-atomic.patch
> z3fold-extend-compaction-function.patch

These are not interdependent.

> Please take a look, figure out what we should do.  Perhaps do it all as
> a coherent series rather than an interdependent dribble?

I'll come up with a 2-patch update in a short while.

~vitaly

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
