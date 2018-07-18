Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yw0-f198.google.com (mail-yw0-f198.google.com [209.85.161.198])
	by kanga.kvack.org (Postfix) with ESMTP id 90A966B0266
	for <linux-mm@kvack.org>; Wed, 18 Jul 2018 18:08:56 -0400 (EDT)
Received: by mail-yw0-f198.google.com with SMTP id t10-v6so3306819ywc.7
        for <linux-mm@kvack.org>; Wed, 18 Jul 2018 15:08:56 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id y185-v6sor1223930yby.53.2018.07.18.15.08.53
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Wed, 18 Jul 2018 15:08:53 -0700 (PDT)
Date: Wed, 18 Jul 2018 18:11:39 -0400
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH 08/10] psi: pressure stall information for CPU, memory,
 and IO
Message-ID: <20180718221139.GF2838@cmpxchg.org>
References: <20180712172942.10094-1-hannes@cmpxchg.org>
 <20180712172942.10094-9-hannes@cmpxchg.org>
 <20180717151705.GH2494@hirez.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20180717151705.GH2494@hirez.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Tejun Heo <tj@kernel.org>, Suren Baghdasaryan <surenb@google.com>, Vinayak Menon <vinmenon@codeaurora.org>, Christopher Lameter <cl@linux.com>, Mike Galbraith <efault@gmx.de>, Shakeel Butt <shakeelb@google.com>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Tue, Jul 17, 2018 at 05:17:05PM +0200, Peter Zijlstra wrote:
> On Thu, Jul 12, 2018 at 01:29:40PM -0400, Johannes Weiner wrote:
> > @@ -457,6 +457,22 @@ config TASK_IO_ACCOUNTING
> >  
> >  	  Say N if unsure.
> >  
> > +config PSI
> > +	bool "Pressure stall information tracking"
> > +	select SCHED_INFO
> 
> What's the deal here? AFAICT it does not in fact use SCHED_INFO for
> _anything_. You just hooked into the sched_info_{en,de}queue() hooks,
> but you don't use any of the sched_info data.
> 
> So the dependency is an artificial one that should not exist.

You're right, it doesn't strictly depend on it. I'll split that out.
