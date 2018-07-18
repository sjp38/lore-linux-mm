Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 4C83A6B0008
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 17:57:24 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id u19-v6so4869527qkl.13
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 14:57:24 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id n84-v6sor2209233qkl.81.2018.07.18.14.57.20
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 14:57:21 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:00:06 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718220006.GC2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717141614.GE2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717141614.GE2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 17, 2018 at 04:16:14PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > +/* Tracked task states */
> > +enum psi_task_count {
> > +	NR_RUNNING,
> > +	NR_IOWAIT,
> > +	NR_MEMSTALL,
> > +	NR_PSI_TASK_COUNTS,
> > +};
> 
> > +/* Resources that workloads could be stalled on */
> > +enum psi_res {
> > +	PSI_CPU,
> > +	PSI_MEM,
> > +	PSI_IO,
> > +	NR_PSI_RESOURCES,
> > +};
> 
> These two have mem and iowait in different order. It really doesn't
> matter, but my brain stumbled.

No problem, I swapped them around for v3.
