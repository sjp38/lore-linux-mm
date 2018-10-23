Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk1-f198.google.com (mail-qk1-f198.google.com [209.85.222.198])
	by kanga.kvack.org (Postfix) with ESMTP id 1C9EA6B0005
	for <linux-mm@kvack.org>; Tue, 23 Oct 2018 13:29:45 -0400 (EDT)
Received: by mail-qk1-f198.google.com with SMTP id u20-v6so2316060qka.21
        for <linux-mm@kvack.org>; Tue, 23 Oct 2018 10:29:45 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id b49-v6sor2249607qta.32.2018.10.23.10.29.37
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Tue, 23 Oct 2018 10:29:37 -0700 (PDT)
Date: Tue, 23 Oct 2018 13:29:37 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/9] psi: pressure stall information for CPU, memory, and
 IO v4
Message-ID: <20181023172937.GA21443@cmpxchg.org>
References: <20180828172258.3185-1-hannes@cmpxchg.org>
 <20181018190710.fcea1c5f9c3b0c15d37ee762@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181018190710.fcea1c5f9c3b0c15d37ee762@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Daniel Drake <drake@endlessm.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Peter Enderborg <peter.enderborg@sony.com>, Shakeel Butt <shakeelb@google.com>, Mike Galbraith <efault@gmx.de>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Oct 18, 2018 at 07:07:10PM -0700, Andrew Morton wrote:
> On Tue, 28 Aug 2018 13:22:49 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> > This version 4 of the PSI series incorporates feedback from Peter and
> > fixes two races in the lockless aggregator that Suren found in his
> > testing and which caused the sample calculation to sometimes underflow
> > and record bogusly large samples; details at the bottom of this email.
> 
> We've had very little in the way of review activity for the PSI
> patchset.  According to the changelog tags, anyway.

Peter reviewed it quite extensively over all revisions, and acked the
final version. Peter, can we add your acked-by or reviewed-by tag(s)?

The scheduler part accounts for 99% of the complexity in those
patches. The mm bits, while somewhat sprawling, are mostly mechanical.
