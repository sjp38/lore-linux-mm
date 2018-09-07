Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f69.google.com (mail-wm0-f69.google.com [74.125.82.69])
	by kanga.kvack.org (Postfix) with ESMTP id 28BB76B7DFB
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 07:04:26 -0400 (EDT)
Received: by mail-wm0-f69.google.com with SMTP id 129-v6so9364821wma.8
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 04:04:26 -0700 (PDT)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:8b0:10b:1231::1])
        by mx.google.com with ESMTPS id c187-v6si5577942wmd.52.2018.09.07.04.04.24
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 07 Sep 2018 04:04:24 -0700 (PDT)
Date: Fri, 7 Sep 2018 13:04:07 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Message-ID: <20180907110407.GQ24106@hirez.programming.kicks-ass.net>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20180905214303.GA30178@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180905214303.GA30178@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Wed, Sep 05, 2018 at 05:43:03PM -0400, Johannes Weiner wrote:
> On Tue, Aug 28, 2018 at 01:22:49PM -0400, Johannes Weiner wrote:
> > This version 4 of the PSI series incorporates feedback from Peter and
> > fixes two races in the lockless aggregator that Suren found in his
> > testing and which caused the sample calculation to sometimes underflow
> > and record bogusly large samples; details at the bottom of this email.
> 
> Peter, do the changes from v3 look sane to you?
> 
> If there aren't any further objections, I was hoping we could get this
> lined up for 4.20.

I suppose it looks ok, there's a few small nits, but nothing big.

I still hate psi_ttwu_dequeue(), but I don't really know what to about
that.

So yeah, grudingly acked. Did you want me to pick this up through the
scheduler tree since most of this lives there?
