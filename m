Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f69.google.com (mail-wr1-f69.google.com [209.85.221.69])
	by kanga.kvack.org (Postfix) with ESMTP id AE2336B7F23
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 11:58:38 -0400 (EDT)
Received: by mail-wr1-f69.google.com with SMTP id q18-v6so12842695wrr.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 08:58:38 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b124-v6sor6108069wmg.0.2018.09.07.08.58.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 08:58:37 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20180907150955.GC11088@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org> <20180905214303.GA30178@cmpxchg.org>
 <20180907110407.GQ24106@hirez.programming.kicks-ass.net> <20180907150955.GC11088@cmpxchg.org>
From: Suren Baghdasaryan <surenb@google.com>
Date: Fri, 7 Sep 2018 08:58:36 -0700
Message-ID: <CAJuCfpG1=pXOg=1GwC33Uy0BcXNq-BsR6dO0JJq4Jnm5TyNENQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

Thanks for the new patchset! Backported to 4.9 and retested on ARMv8 8
code system running Android. Signals behave as expected reacting to
memory pressure, no jumps in "total" counters that would indicate an
overflow/underflow issues. Nicely done!

Tested-by: Suren Baghdasaryan <surenb@google.com>

On Fri, Sep 7, 2018 at 8:09 AM, Johannes Weiner <hannes@cmpxchg.org> wrote:
> On Fri, Sep 07, 2018 at 01:04:07PM +0200, Peter Zijlstra wrote:
>> So yeah, grudingly acked. Did you want me to pick this up through the
>> scheduler tree since most of this lives there?
>
> Thanks for the ack.
>
> As for routing it, I'll leave that decision to you and Andrew. It
> touches stuff all over, so it could result in quite a few conflicts
> between trees (although I don't expect any of them to be non-trivial).
