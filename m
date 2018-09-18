Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id 7A9BD8E0001
	for <linux-mm@kvack.org>; Tue, 18 Sep 2018 12:03:07 -0400 (EDT)
Received: by mail-wm1-f72.google.com with SMTP id b186-v6so1347986wmh.8
        for <linux-mm@kvack.org>; Tue, 18 Sep 2018 09:03:07 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v5-v6sor13724559wrs.35.2018.09.18.09.03.06
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 18 Sep 2018 09:03:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <29f0bb2c-31d4-0b2e-d816-68076b90e9d3@sony.com>
References: <20180828172258.3185-1-hannes@cmpxchg.org> <20180905214303.GA30178@cmpxchg.org>
 <20180907110407.GQ24106@hirez.programming.kicks-ass.net> <20180907150955.GC11088@cmpxchg.org>
 <CAJuCfpG1=pXOg=1GwC33Uy0BcXNq-BsR6dO0JJq4Jnm5TyNENQ@mail.gmail.com> <29f0bb2c-31d4-0b2e-d816-68076b90e9d3@sony.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 18 Sep 2018 09:03:05 -0700
Message-ID: <CAJuCfpFSTEBySRR2X=3b5+pHP_J1MBqfPXPJCUVajGF6AwJDpA@mail.gmail.com>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peter enderborg <peter.enderborg@sony.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

On Mon, Sep 17, 2018 at 6:29 AM, peter enderborg
<peter.enderborg@sony.com> wrote:
> Will it be part of the backport to 4.9 google android or is it for test only?

Currently I'm testing these patches in tandem with PSI monitor that
I'm developing and test results look good. If things go well and we
start using PSI for Android I will try to upstream the backport. If
upstream rejects it we will have to merge it into Android common
kernel repo as a last resort. Hope this answers your question.

> I guess that this patch is to big for the LTS tree.
>
> On 09/07/2018 05:58 PM, Suren Baghdasaryan wrote:
>> Thanks for the new patchset! Backported to 4.9 and retested on ARMv8 8
>> code system running Android. Signals behave as expected reacting to
>> memory pressure, no jumps in "total" counters that would indicate an
>> overflow/underflow issues. Nicely done!
>>
>> Tested-by: Suren Baghdasaryan <surenb@google.com>
>>
>> On Fri, Sep 7, 2018 at 8:09 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
>>> On Fri, Sep 07, 2018 at 01:04:07PM +0200, Peter Zijlstra wrote:
>>>> So yeah, grudingly acked. Did you want me to pick this up through the
>>>> scheduler tree since most of this lives there?
>>> Thanks for the ack.
>>>
>>> As for routing it, I'll leave that decision to you and Andrew. It
>>> touches stuff all over, so it could result in quite a few conflicts
>>> between trees (although I don't expect any of them to be non-trivial).
>
>

Thanks,
Suren.
