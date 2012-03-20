Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx105.postini.com [74.125.245.105])
	by kanga.kvack.org (Postfix) with SMTP id 6A7D46B0044
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 19:41:09 -0400 (EDT)
From: Dan Smith <danms@us.ibm.com>
Subject: Re: [RFC] AutoNUMA alpha6
References: <20120316144028.036474157@chello.nl>
	<20120316182511.GJ24602@redhat.com>
Date: Tue, 20 Mar 2012 16:41:06 -0700
In-Reply-To: <20120316182511.GJ24602@redhat.com> (Andrea Arcangeli's message
	of "Fri, 16 Mar 2012 19:25:11 +0100")
Message-ID: <87k42edenh.fsf@danplanet.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

AA> Could you try my two trivial benchmarks I sent on lkml too?

I just got around to running your numa01 test on mainline, autonuma, and
numasched.  This is on a 2-socket, 6-cores-per-socket,
2-threads-per-core machine, with your test configured to run 24
threads. I also ran Peter's modified stream_d on all three as well, with
24 instances in parallel. I know it's already been pointed out that it's
not the ideal or end-all benchmark, but I figured it was still
worthwhile to see if the trend continued.

On your numa01 test:

  Autonuma is 22% faster than mainline
  Numasched is 42% faster than mainline

On Peter's modified stream_d test:

  Autonuma is 35% *slower* than mainline
  Numasched is 55% faster than mainline

I know that the "real" performance guys here are going to be posting
some numbers from more interesting benchmarks soon, but since nobody
had answered Andrea's question, I figured I'd do it.

-- 
Dan Smith
IBM Linux Technology Center

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
