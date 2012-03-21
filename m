Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx178.postini.com [74.125.245.178])
	by kanga.kvack.org (Postfix) with SMTP id D97166B007E
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 00:02:01 -0400 (EDT)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316144028.036474157@chello.nl>
	<20120316182511.GJ24602@redhat.com> <87k42edenh.fsf@danplanet.com>
	<20120321021239.GQ24602@redhat.com>
Date: Tue, 20 Mar 2012 21:01:58 -0700
In-Reply-To: <20120321021239.GQ24602@redhat.com> (Andrea Arcangeli's message
	of "Wed, 21 Mar 2012 03:12:39 +0100")
Message-ID: <87fwd2d2kp.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

AA>         upstream autonuma numasched hard inverse
AA> numa02  64       45       66        42   81
AA> numa01  491      328      607       321  623 -D THREAD_ALLOC
AA> numa01  305      207      338       196  378 -D NO_BIND_FORCE_SAME_NODE

AA> So give me a break... you must have made a real mess in your
AA> benchmarking.

I'm just running what you posted, dude :)

AA> numasched is always doing worse than upstream here, in fact two
AA> times massively worse. Almost as bad as the inverse binds.

Well, something clearly isn't right, because my numbers don't match
yours at all. This time with THP disabled, and compared to the rest of
the numbers from my previous runs:

            autonuma   HARD   INVERSE   NO_BIND_FORCE_SAME_MODE

numa01      366        335    356       377
numa01THP   388        336    353       399

That shows that autonuma is worse than inverse binds here. If I'm
running your stuff incorrectly, please tell me and I'll correct
it. However, I've now compiled the binary exactly as you asked, with THP
disabled, and am seeing surprisingly consistent results.

AA> Maybe you've more than 16g? I've 16G and that leaves 1G free on both
AA> nodes at the peak load with AutoNUMA. That shall be enough for
AA> numasched too (Peter complained me I waste 80MB on a 16G system, so
AA> he can't possibly be intentionally wasting me 2GB).

Yep, 24G here. Do I need to tweak the test?

AA> In any case your results were already _obviously_ broken without me
AA> having to benchmark numasched to verify, because it's impossible
AA> numasched could be 20% faster than autonuma on numa01, because
AA> otherwise it would mean that numasched is like 18% faster than hard
AA> bindings which is mathematically impossible unless your hardware is
AA> not NUMA or superNUMAbroken.

How do you figure? I didn't post any hard binding numbers. In fact,
numasched performed about equal to hard binding...definitely within your
stated 2% error interval. That was with THP enabled, tomorrow I'll be
glad to run them all again without THP.

-- 
Dan Smith
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
