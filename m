Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id D91156B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 03:31:52 -0400 (EDT)
Received: by wgbdt10 with SMTP id dt10so187124wgb.2
        for <linux-mm@kvack.org>; Tue, 20 Mar 2012 00:31:51 -0700 (PDT)
Date: Tue, 20 Mar 2012 08:31:47 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120320073147.GA27213@gmail.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332164371.18960.339.camel@twins>
 <20120319142046.GP24602@redhat.com>
 <alpine.DEB.2.00.1203191513110.23632@router.home>
 <20120319202846.GA26555@gmail.com>
 <CA+55aFwa-81x2Dysk8WS8ez2WkYSbaQDyQvpH0qE7fGJgxTbUQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
Content-Transfer-Encoding: 8bit
In-Reply-To: <CA+55aFwa-81x2Dysk8WS8ez2WkYSbaQDyQvpH0qE7fGJgxTbUQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Linus Torvalds <torvalds@linux-foundation.org> wrote:

> On Mon, Mar 19, 2012 at 1:28 PM, Ingo Molnar <mingo@kernel.org> wrote:
> >
> > That having said PeterZ's numbers showed some pretty good
> > improvement for the streams workload:
> >
> >  before: 512.8M
> >  after: 615.7M
> >
> > i.e. a +20% improvement on a not very heavily NUMA box.
> 
> Well, streams really isn't a very interesting benchmark. It's 
> the traditional single-threaded cpu-only thing that just 
> accesses things linearly, and I'm not convinced the numbers 
> should be taken to mean anything at all.

Yeah, I considered it the 'ideal improvement' for memory-bound, 
private-working-set workloads on commodity hardware - i.e. the 
upper envelope of anything that might matter. We don't know the 
worst-case regression percentage, nor the median improvement - 
which might very well be a negative number.

More fundamentally we don't even know whether such access 
patterns matter at all.

> The HPC people want to multi-thread things these days, and 
> "cpu/memory affinity" is a lot less clear then.
> 
> So I can easily imagine that the performance improvement is 
> real, but I really don't think "streams improves by X %" is 
> all that interesting. Are there any more relevant loads that 
> actually matter to people that we could show improvement on?

That would be interesting to see.

I could queue this up in a topical branch in a pure opt-in 
fashion, to make it easier to test.

Assuming there will be real improvements on real workloads, do 
you have any fundamental objections against the 'home node' 
concept itself and its placement into mm_struct? I think it 
makes sense and mm_struct is the most logical place to host it.

The rest looks rather non-controversial to me, apps that want 
more memory affinity should get it and both the VM and the 
scheduler should help achieve that goal, within memory and CPU 
allocation constraints.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
