Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx121.postini.com [74.125.245.121])
	by kanga.kvack.org (Postfix) with SMTP id 52C176B0104
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:17:45 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:17:39 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
In-Reply-To: <20120319142046.GP24602@redhat.com>
Message-ID: <alpine.DEB.2.00.1203191513110.23632@router.home>
References: <20120316144028.036474157@chello.nl> <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins> <20120319130401.GI24602@redhat.com> <1332164371.18960.339.camel@twins> <20120319142046.GP24602@redhat.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 Mar 2012, Andrea Arcangeli wrote:

> Yeah I'll try to fix that but it's massively complex and frankly
> benchmarking wise it won't help much fixing that... so it's beyond the
> end of my todo list.

Well a word of caution here: SGI tried to implement automatic migration
schemes back in the 90's but they were never able to show a general
benefit of migration. The overhead added because of auto migration often
was not made up by true acceleration of the applications running on the
system. They were able to tune the automatic migration to work on
particular classes of applications but it never turned out to be generally
advantageous.

I wonder how we can verify that the automatic migration schemes are a real
benefit to the application? We have a history of developing a kernel that
decreases in performance as development proceeds. How can we make sure
that these schemes are actually beneficial overall for all loads and do
not cause regressions elsewhere?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
