Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr1-f70.google.com (mail-wr1-f70.google.com [209.85.221.70])
	by kanga.kvack.org (Postfix) with ESMTP id C70EF8E00A4
	for <linux-mm@kvack.org>; Tue, 25 Sep 2018 18:05:10 -0400 (EDT)
Received: by mail-wr1-f70.google.com with SMTP id u1-v6so2495173wrt.3
        for <linux-mm@kvack.org>; Tue, 25 Sep 2018 15:05:10 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id h13-v6sor2706895wrv.32.2018.09.25.15.05.09
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 25 Sep 2018 15:05:09 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJuCfpEmFC94HYkfDSruhrBzvnEWqFO87RXkb7MDb6yV40wPPg@mail.gmail.com>
References: <20180828172258.3185-1-hannes@cmpxchg.org> <20180905214303.GA30178@cmpxchg.org>
 <20180907110407.GQ24106@hirez.programming.kicks-ass.net> <20180907150955.GC11088@cmpxchg.org>
 <CAJuCfpG1=pXOg=1GwC33Uy0BcXNq-BsR6dO0JJq4Jnm5TyNENQ@mail.gmail.com>
 <CAD8Lp47F5N8xN41KFHybVVTpV_TEewERD-eJov6iiqBJUyVR9g@mail.gmail.com> <CAJuCfpEmFC94HYkfDSruhrBzvnEWqFO87RXkb7MDb6yV40wPPg@mail.gmail.com>
From: Suren Baghdasaryan <surenb@google.com>
Date: Tue, 25 Sep 2018 15:05:08 -0700
Message-ID: <CAJuCfpHwGatVx6ke6k_Bui5Vuum+ZnmhEPEG1PY43kqdaLQNBQ@mail.gmail.com>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Daniel Drake <drake@endlessm.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

I emailed Daniel 4.9 backport patches. Unfortunately that seems to be
the easiest way to share them. If anyone else is interested in them
please email me directly.
Thanks,
Suren.


On Tue, Sep 18, 2018 at 8:53 AM, Suren Baghdasaryan <surenb@google.com> wrote:
> Hi Daniel,
>
> On Sun, Sep 16, 2018 at 10:22 PM, Daniel Drake <drake@endlessm.com> wrote:
>> Hi Suren
>>
>> On Fri, Sep 7, 2018 at 11:58 PM, Suren Baghdasaryan <surenb@google.com> wrote:
>>> Thanks for the new patchset! Backported to 4.9 and retested on ARMv8 8
>>> code system running Android. Signals behave as expected reacting to
>>> memory pressure, no jumps in "total" counters that would indicate an
>>> overflow/underflow issues. Nicely done!
>>
>> Can you share your Linux v4.9 psi backport somewhere?
>>
>
> Absolutely. Let me figure out what's the best way to do share that and
> make sure they apply cleanly on official 4.9 (I was using vendor's
> tree for testing). Will need a day or so to get this done.
> In case you need them sooner, there were several "prerequisite"
> patches that I had to backport to make PSI backporting
> easier/possible. Following is the list as shown by "git log
> --oneline":
>
> PSI patches:
>
> ef94c067f360 psi: cgroup support
> 60081a7aeb0b psi: pressure stall information for CPU, memory, and IO
> acd2a16497e9 sched: introduce this_rq_lock_irq()
> f30268c29309 sched: sched.h: make rq locking and clock functions
> available in stats.h
> a2fd1c94b743 sched: loadavg: make calc_load_n() public
> 32a74dec4967 sched: loadavg: consolidate LOAD_INT, LOAD_FRAC, CALC_LOAD
> 8e3991dd1a73 delayacct: track delays from thrashing cache pages
> 4ae940e7e6ff mm: workingset: tell cache transitions from workingset thrashing
> e9ccd63399e0 mm: workingset: don't drop refault information prematurely
>
> Prerequisites:
>
> b5a58c778c54 workqueue: make workqueue available early during boot
> ae5f39ee13b5 sched/core: Add wrappers for lockdep_(un)pin_lock()
> 7276f98a72c1 sched/headers, delayacct: Move the 'struct
> task_delay_info' definition from <linux/sched.h> to
> <linux/delayacct.h>
> 287318d13688 mm: add PageWaiters indicating tasks are waiting for a page bit
> edfa64560aaa sched/headers: Remove <linux/sched.h> from <linux/sched/loadavg.h>
> f6b6ba853959 sched/headers: Move loadavg related definitions from
> <linux/sched.h> to <linux/sched/loadavg.h>
> 395b0a9f7aae sched/headers: Prepare for new header dependencies before
> moving code to <linux/sched/loadavg.h>
>
> PSI patches needed some adjustments but nothing really major.
>
>> Thanks
>> Daniel
>
> Thanks,
> Suren.
