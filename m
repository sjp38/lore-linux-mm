Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx202.postini.com [74.125.245.202])
	by kanga.kvack.org (Postfix) with SMTP id 9136A6B006C
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 08:40:54 -0400 (EDT)
Message-ID: <1341837624.3462.68.camel@twins>
Subject: Re: [RFC][PATCH 14/26] sched, numa: Numa balancer
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 09 Jul 2012 14:40:24 +0200
In-Reply-To: <1341836629.3462.60.camel@twins>
References: <20120316144028.036474157@chello.nl>
	 <20120316144241.012558280@chello.nl> <4FF87F5F.30106@redhat.com>
	 <1341836629.3462.60.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-07-09 at 14:23 +0200, Peter Zijlstra wrote:
> > It is not yet clear to me how and why your code converges.
>=20
> I don't think it does.. but since the scheduler interaction is fairly
> weak it doesn't matter too much from that pov.
>=20
That is,.. it slowly moves along with the cpu usage, only if there's a
lot of remote memory allocations (memory pressure) things get funny.=20

It'll try and rotate all tasks around a bit trying, but there's no good
solution for a memory hole on one node and a cpu hole on another, you're
going to have to take the remote hits.

Again.. what do we want it to do?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
