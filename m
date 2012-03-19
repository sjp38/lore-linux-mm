Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx117.postini.com [74.125.245.117])
	by kanga.kvack.org (Postfix) with SMTP id 252496B0106
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:29:00 -0400 (EDT)
Received: by werm1 with SMTP id m1so1427148wer.2
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 13:28:58 -0700 (PDT)
Date: Mon, 19 Mar 2012 21:28:49 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319202846.GA26555@gmail.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <20120319130401.GI24602@redhat.com>
 <1332164371.18960.339.camel@twins>
 <20120319142046.GP24602@redhat.com>
 <alpine.DEB.2.00.1203191513110.23632@router.home>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.1203191513110.23632@router.home>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org


* Christoph Lameter <cl@linux.com> wrote:

> On Mon, 19 Mar 2012, Andrea Arcangeli wrote:
> 
> > Yeah I'll try to fix that but it's massively complex and 
> > frankly benchmarking wise it won't help much fixing that... 
> > so it's beyond the end of my todo list.
> 
> Well a word of caution here: SGI tried to implement automatic 
> migration schemes back in the 90's but they were never able to 
> show a general benefit of migration. The overhead added 
> because of auto migration often was not made up by true 
> acceleration of the applications running on the system. They 
> were able to tune the automatic migration to work on 
> particular classes of applications but it never turned out to 
> be generally advantageous.

Obviously any such scheme must be a win in general for it to be 
default on. We don't have the numbers to justify that - and I'm 
sceptical whether it will be possible, but I'm willing to be 
surprised.

I'm especially sceptical since most mainstream NUMA systems tend 
to have a low NUMA factor. Thus the actual cost of being NUMA is 
pretty low.

That having said PeterZ's numbers showed some pretty good 
improvement for the streams workload:

 before: 512.8M
  after: 615.7M

i.e. a +20% improvement on a not very heavily NUMA box.

That kind of raw speedup of a CPU execution workload like 
streams is definitely not something to ignore out of hand. *IF* 
there is a good automatism that can activate it for the apps 
that are very likely to benefit from it then we can possibly do 
it.

But a lot more measurements have to be done, and I'd be also 
very interested in the areas that regress.

Otherwise, if no robust automation is possible, it will have to 
be opt-in, on a per app basis, with both programmatic and 
sysadmin knobs available. (who will hopefully make use if it...)

That's the best we can do I think.

> I wonder how we can verify that the automatic migration 
> schemes are a real benefit to the application? We have a 
> history of developing a kernel that decreases in performance 
> as development proceeds. How can we make sure that these 
> schemes are actually beneficial overall for all loads and do 
> not cause regressions elsewhere? [...]

The usual way?

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
