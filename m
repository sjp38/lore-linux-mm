Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx127.postini.com [74.125.245.127])
	by kanga.kvack.org (Postfix) with SMTP id 801636B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:40:55 -0400 (EDT)
Date: Mon, 19 Mar 2012 14:40:29 +0100
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Message-ID: <20120319134029.GK24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
 <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins>
 <4F671B90.3010209@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <4F671B90.3010209@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 01:42:08PM +0200, Avi Kivity wrote:
> Extra work, and more slowness until they get rebuilt.  Why not migrate
> entire large pages?

The main problem is the double copy, first copy for migrate, second
for khugepaged. This is why we want it native over time. So it also
only stops the accesses to the pages for a shorter period of time.

> I agree with this, but it's really widespread throughout the kernel,
> from interrupts to work items to background threads.  It needs to be
> solved generically (IIRC vhost has some accouting fix for a similar issue).

Exactly.

> It's the standard space/time tradeoff.  Once solution wants more
> storage, the other wants more faults.

I didn't grow it much more than memcg, and at least if you boot on
NUMA hardware you'll be sure to use AutoNUMA. The fact it's in the
struct page it's an implementation detail, it'll only be allocated if
the kernel is booted on NUMA hardware later.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
