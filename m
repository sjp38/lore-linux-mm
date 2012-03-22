Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx153.postini.com [74.125.245.153])
	by kanga.kvack.org (Postfix) with SMTP id 47F146B0044
	for <linux-mm@kvack.org>; Thu, 22 Mar 2012 14:56:41 -0400 (EDT)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316182511.GJ24602@redhat.com> <87k42edenh.fsf@danplanet.com>
	<20120321021239.GQ24602@redhat.com> <87fwd2d2kp.fsf@danplanet.com>
	<20120321124937.GX24602@redhat.com> <87limtboet.fsf@danplanet.com>
	<20120321225242.GL24602@redhat.com>
	<20120322001722.GQ24602@redhat.com> <873990buuy.fsf@danplanet.com>
	<20120322142735.GE24602@redhat.com>
	<20120322184925.GT24602@redhat.com>
Date: Thu, 22 Mar 2012 11:56:37 -0700
In-Reply-To: <20120322184925.GT24602@redhat.com> (Andrea Arcangeli's message
	of "Thu, 22 Mar 2012 19:49:25 +0100")
Message-ID: <87limsa2hm.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

AA> but now it's time to go back coding and add THP native
AA> migration. That will benefit everyone, from cpuset in userland to
AA> numa/sched.

I dunno about everyone else, but I think the thing I'd like to see most
(other than more interesting benchmarks) is a broken out and documented
set of patches instead of the monolithic commit you have now. I know you
weren't probably planning to do that until numasched came along, but it
sure would help me digest the differences in the two approaches.

-- 
Dan Smith
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
