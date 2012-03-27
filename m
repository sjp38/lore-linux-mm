Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx138.postini.com [74.125.245.138])
	by kanga.kvack.org (Postfix) with SMTP id AE22F6B00FF
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 12:04:56 -0400 (EDT)
Date: Tue, 27 Mar 2012 18:04:22 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 07/39] autonuma: introduce kthread_bind_node()
Message-ID: <20120327160422.GR5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
 <1332783986-24195-8-git-send-email-aarcange@redhat.com>
 <1332786755.16159.174.camel@twins>
 <20120327152209.GL5906@redhat.com>
 <1332863135.16159.239.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1332863135.16159.239.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

On Tue, Mar 27, 2012 at 05:45:35PM +0200, Peter Zijlstra wrote:
> On Tue, 2012-03-27 at 17:22 +0200, Andrea Arcangeli wrote:
> > I don't see what's wrong with more than 1 CPU in the hard bind
> > cpumask.
> 
> Because its currently broken, but we're trying to restore its pure
> semantic so that we can use it in more places again, like
> debug_smp_processor_id(). Testing a single process flag is _much_
> cheaper than testing ->cpus_allowed.
> 
> Adding more broken isn't an option.

I would suggest you to use a new bitflag for that _future_
optimization that you plan to do without altering the way the current
bitflag works.

I doubt knuma_migrated will ever be the only kernel thread that wants
to run with a NUMA NODE-wide CPU binding (instead of single-CPU
binding).

Being able to keep using this bitflag for NUMA-wide bindings too in
the future as well (after you do the optimization you planned), is
going to reduce the chances of the root user shooting himself in the
foot for both the kernel thread node-BIND and the single-cpu-BIND.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
