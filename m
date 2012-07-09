Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx161.postini.com [74.125.245.161])
	by kanga.kvack.org (Postfix) with SMTP id 40A466B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:24:14 -0400 (EDT)
Message-ID: <1341836629.3462.60.camel@twins>
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jul 2012 14:23:49 +0200
In-Reply-To: <4FF87F5F.30106@redhat.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144241.012558280@chello.nl> <4FF87F5F.30106@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2012-07-07 at 14:26 -0400, Rik van Riel wrote:
>=20
> You asked how and why Andrea's algorithm converges.
> After looking at both patch sets for a while, and asking
> for clarification, I think I can see how his code converges.

Do share.. what does it balance on and where does it converge to?

> It is not yet clear to me how and why your code converges.

I don't think it does.. but since the scheduler interaction is fairly
weak it doesn't matter too much from that pov.

> I see some dual bin packing (CPU & memory) heuristics, but
> it is not at all clear to me how they interact, especially
> when workloads are going active and idle on a regular basis.
>=20
Right, this is the bit I wanted discussion on most.. it is not at all
clear to me what one would want it to do. Given sufficient memory you'd
want it to slowly follow the cpu load. However on memory pressure you
can't do that.

Spreading memory evenly across nodes doesn't make much sense if the
compute time and capacity isn't matched either.

Also a pond will never settle if you keep throwing rocks in, you need
semi-stable operation conditions for anything to make sense. So the only
thing to consider for the wildly dynamic case is not going bananas along
with it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
