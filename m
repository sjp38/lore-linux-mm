Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb1-f198.google.com (mail-yb1-f198.google.com [209.85.219.198])
	by kanga.kvack.org (Postfix) with ESMTP id EA61C6B7EF5
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 11:10:03 -0400 (EDT)
Received: by mail-yb1-f198.google.com with SMTP id q65-v6so5680432ybg.12
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 08:10:03 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l195-v6sor458419ybl.121.2018.09.07.08.09.58
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 08:09:58 -0700 (PDT)
Date: Fri, 7 Sep 2018 11:09:55 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Message-ID: <20180907150955.GC11088@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180905214303.GA30178@cmpxchg.org>
 <20180907110407.GQ24106@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180907110407.GQ24106@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Fri, Sep 07, 2018 at 01:04:07PM +0200, Peter Zijlstra wrote:
> So yeah, grudingly acked. Did you want me to pick this up through the
> scheduler tree since most of this lives there?

Thanks for the ack.

As for routing it, I'll leave that decision to you and Andrew. It
touches stuff all over, so it could result in quite a few conflicts
between trees (although I don't expect any of them to be non-trivial).
