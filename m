Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx191.postini.com [74.125.245.191])
	by kanga.kvack.org (Postfix) with SMTP id 707B96B0081
	for <linux-mm@kvack.org>; Sat, 26 May 2012 13:28:48 -0400 (EDT)
Message-ID: <4FC112AB.1040605@redhat.com>
Date: Sat, 26 May 2012 13:28:11 -0400
From: Rik van Riel <riel@redhat.com>
MIME-Version: 1.0
Subject: Re: [PATCH 00/35] AutoNUMA alpha14
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
In-Reply-To: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On 05/25/2012 01:02 PM, Andrea Arcangeli wrote:

> I believe (realistically speaking) nobody is going to change
> applications to specify which thread is using which memory (for
> threaded apps) with the only exception of QEMU and a few others.

This is the point of contention.  I believe that for some
programs these kinds of modifications might happen, but
that for some other programs - managed runtimes like JVMs -
it is fundamentally impossible to do proper NUMA hinting,
because the programming languages that run on top of the
runtimes have no concept of pointers or memory ranges, making
it impossible to do those kinds of hints without fundamentally
changing the programming languages in question.

It would be good to get everybody's ideas out there on this
topic, because this is the fundamental factor in deciding
between Peter's approach to NUMA and Andrea's approach.

Ingo? Andrew? Linus? Paul?

> For not threaded apps that fits in a NUMA node, there's no way a blind
> home node can perform nearly as good as AutoNUMA:

The small tasks are easy. I suspect that either implementation
can be tuned to produce good results there.

It is the large programs (that do not fit in a NUMA node, either
due to too much memory, or due to too many threads) that will
force our hand in deciding whether to go with Peter's approach
or your approach.

I believe we do need to carefully think about this issue, decide
on a NUMA approach based on the fundamental technical properties of
each approach.

After we figure out what we want to do, we can nit-pick on the
codebase in question, and make sure it gets completely fixed.
I am sure neither codebase is perfect right now, but both are
entirely fixable.

-- 
All rights reversed

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
