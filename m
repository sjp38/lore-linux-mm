Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f71.google.com (mail-oi0-f71.google.com [209.85.218.71])
	by kanga.kvack.org (Postfix) with ESMTP id 0854E8E0001
	for <linux-mm@kvack.org>; Mon, 17 Sep 2018 01:22:17 -0400 (EDT)
Received: by mail-oi0-f71.google.com with SMTP id u74-v6so17063676oie.16
        for <linux-mm@kvack.org>; Sun, 16 Sep 2018 22:22:17 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id r64-v6sor12279502oib.119.2018.09.16.22.22.15
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Sun, 16 Sep 2018 22:22:15 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <CAJuCfpG1=pXOg=1GwC33Uy0BcXNq-BsR6dO0JJq4Jnm5TyNENQ@mail.gmail.com>
References: <20180828172258.3185-1-hannes@cmpxchg.org> <20180905214303.GA30178@cmpxchg.org>
 <20180907110407.GQ24106@hirez.programming.kicks-ass.net> <20180907150955.GC11088@cmpxchg.org>
 <CAJuCfpG1=pXOg=1GwC33Uy0BcXNq-BsR6dO0JJq4Jnm5TyNENQ@mail.gmail.com>
From: Daniel Drake <drake@endlessm.com>
Date: Mon, 17 Sep 2018 13:22:14 +0800
Message-ID: <CAD8Lp47F5N8xN41KFHybVVTpV_TEewERD-eJov6iiqBJUyVR9g@mail.gmail.com>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Content-Type: text/plain; charset="UTF-8"
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Suren Baghdasaryan <surenb@google.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm <linux-mm@kvack.org>, cgroups@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>, kernel-team@fb.com

Hi Suren

On Fri, Sep 7, 2018 at 11:58 PM, Suren Baghdasaryan <surenb@google.com> wrote:
> Thanks for the new patchset! Backported to 4.9 and retested on ARMv8 8
> code system running Android. Signals behave as expected reacting to
> memory pressure, no jumps in "total" counters that would indicate an
> overflow/underflow issues. Nicely done!

Can you share your Linux v4.9 psi backport somewhere?

Thanks
Daniel
