Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg1-f200.google.com (mail-pg1-f200.google.com [209.85.215.200])
	by kanga.kvack.org (Postfix) with ESMTP id 760456B000A
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:41:29 -0400 (EDT)
Received: by mail-pg1-f200.google.com with SMTP id i19-v6so509026pgb.19
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:41:29 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id f1-v6si1753725pgv.468.2018.10.23.10.41.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Tue, 23 Oct 2018 10:41:28 -0700 (PDT)
Date: Tue, 23 Oct 2018 19:41:15 +0200
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Message-ID: <20181023174115.GB3126@worktop.c.hoisthospitality.com>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20181018190710.fcea1c5f9c3b0c15d37ee762@linux-foundation.org>
 <20181023172937.GA21443@cmpxchg.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181023172937.GA21443@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Oct 23, 2018 at 01:29:37PM -0400, Johannes Weiner wrote:
> On Thu, Oct 18, 2018 at 07:07:10PM -0700, Andrew Morton wrote:
> > On Tue, 28 Aug 2018 13:22:49 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> > 
> > > This version 4 of the PSI series incorporates feedback from Peter and
> > > fixes two races in the lockless aggregator that Suren found in his
> > > testing and which caused the sample calculation to sometimes underflow
> > > and record bogusly large samples; details at the bottom of this email.
> > 
> > We've had very little in the way of review activity for the PSI
> > patchset.  According to the changelog tags, anyway.
> 
> Peter reviewed it quite extensively over all revisions, and acked the
> final version. Peter, can we add your acked-by or reviewed-by tag(s)?

I don't really do reviewed by; but yes, I thought I already did; lemme
find.

> The scheduler part accounts for 99% of the complexity in those
> patches. The mm bits, while somewhat sprawling, are mostly mechanical.

Ah, I now see my mistake;

  https://lkml.kernel.org/r/20180907110407.GQ24106@hirez.programming.kicks-ass.net

I forgot to include an actual tag therein. My bad.

Acked-by: Peter Zijlstra (Intel) <peterz@infradead.org>
