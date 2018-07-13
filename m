Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yb0-f200.google.com (mail-yb0-f200.google.com [209.85.213.200])
	by kanga.kvack.org (Postfix) with ESMTP id 096E16B0007
	for <linux-mm@kvack.org>; Fri, 13 Jul 2018 18:11:27 -0400 (EDT)
Received: by mail-yb0-f200.google.com with SMTP id x13-v6so29473175ybl.17
        for <linux-mm@kvack.org>; Fri, 13 Jul 2018 15:11:27 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id o82-v6sor5840135ywb.494.2018.07.13.15.11.23
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 13 Jul 2018 15:11:23 -0700 (PDT)
Date: Fri, 13 Jul 2018 18:14:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 0/10] psi: pressure stall information for CPU, memory,
 and IO v2
Message-ID: <20180713221042.GA30013@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712164422.a53cc0f9c26b078dbc7e5731@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180712164422.a53cc0f9c26b078dbc7e5731@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Ingo Molnar <mingo@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Thu, Jul 12, 2018 at 04:44:22PM -0700, Andrew Morton wrote:
> On Thu, 12 Jul 2018 13:29:32 -0400 Johannes Weiner <hannes@cmpxchg.org> wrote:
> 
> >
> > ...
> >
> > The io file is similar to memory. Because the block layer doesn't have
> > a concept of hardware contention right now (how much longer is my IO
> > request taking due to other tasks?), it reports CPU potential lost on
> > all IO delays, not just the potential lost due to competition.
> 
> Probably dumb question: disks aren't the only form of IO.  Does it make
> sense to accumulate PSI for other forms of IO?  Networking comes to
> mind...

It's conceivable, although I haven't thought too much about it yet. If
that turns out to be a state we might want to track, we can easily add
a task state to identify such stalls and add /proc/pressure/net e.g.

"io" in this case means only the block layer / filesystems. I think
keeping this distinction makes sense in the interest of identifying
which type of hardware resource is posing a pressure problem.
