Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx152.postini.com [74.125.245.152])
	by kanga.kvack.org (Postfix) with SMTP id 328006B0044
	for <linux-mm@kvack.org>; Wed, 21 Mar 2012 20:17:59 -0400 (EDT)
Date: Thu, 22 Mar 2012 01:17:22 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC] AutoNUMA alpha6
Message-ID: <20120322001722.GQ24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <20120316182511.GJ24602@redhat.com>
 <87k42edenh.fsf@danplanet.com>
 <20120321021239.GQ24602@redhat.com>
 <87fwd2d2kp.fsf@danplanet.com>
 <20120321124937.GX24602@redhat.com>
 <87limtboet.fsf@danplanet.com>
 <20120321225242.GL24602@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120321225242.GL24602@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Smith <danms@us.ibm.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Wed, Mar 21, 2012 at 11:52:42PM +0100, Andrea Arcangeli wrote:
> Your three numbers of mainline looked ok, it's still strange that
> numa01_same_node is identical to numa01_inverse_bind though. It
> shoudln't. same_node uses 1 numa node. inverse uses both nodes but

The only reasonable explanation I can imagine for the weird stuff
going on with "numa01_inverse" is that maybe it was compiled without
-DHARD_BIND? I forgot to specify -DINVERSE_BIND is a noop unless
-DHARD_BIND is specified too at the same time. -DINVERSE_BIND alone
results in the default build without -D parameters.

Now AutoNUMA has a bug and is real inverse bind too, I need to fix that.

In the meantime this is possible:

echo 0 >/sys/kernel/mm/autonuma/enabled
run numa01_inverse
echo 1 >/sys/kernel/mm/autonuma/enabled

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
