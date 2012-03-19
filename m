Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 17B466B004D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:26:59 -0400 (EDT)
Message-ID: <1332163594.18960.335.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 14:26:34 +0100
In-Reply-To: <20120319130401.GI24602@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	 <20120319130401.GI24602@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 14:04 +0100, Andrea Arcangeli wrote:

> About the cost of the actual pagetable scanner, you're not being
> rational about it. You should measure it for once, take khugepaged
> make it scan 1G of memory per millisecond and measure the cost.

Death by a thousand cuts..=20

> You keep complaining about the unaccountability of the pagetable
> scanners in terms of process load, and that's a red herring as far as
> I can tell. The irqs and ksoftirqd load in a busy server, is likely
> much higher than whatever happens at the pagetable scanner level (sure
> thing for khugepaged and by an huge order of magnitude so).=20

Who says I agree with ksoftirqd? I would love to get rid of all things
softirq. And I also think workqueues are over-/ab-used.

> I don't
> think this is a relevant concern anyway because the pagetable scanners
> go over all memory in a equal amount so the cost would be evenly
> distributed for all processes over time (the same cannot be said about
> the irqs and ksoftrqid that will benefit only a few processes doing
> I/O).=20

So what about the case where all I do is compile kernels and we already
have near perfect locality because everything is short running? You're
still scanning that memory, and I get no benefit.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
