Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx131.postini.com [74.125.245.131])
	by kanga.kvack.org (Postfix) with SMTP id 38B3C6B006E
	for <linux-mm@kvack.org>; Mon,  9 Jul 2012 10:56:28 -0400 (EDT)
Message-ID: <1341845758.3462.84.camel@twins>
Subject: Re: [RFC][PATCH 25/26] sched, numa: Only migrate long-running
 entities
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 09 Jul 2012 16:55:58 +0200
In-Reply-To: <4FFAF067.3050905@redhat.com>
References: <20120316144028.036474157@chello.nl>
	  <20120316144241.749359061@chello.nl> <4FF9D29D.8030903@redhat.com>
	 <1341836787.3462.64.camel@twins> <4FFAF067.3050905@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-07-09 at 10:53 -0400, Rik van Riel wrote:
> On 07/09/2012 08:26 AM, Peter Zijlstra wrote:
> > On Sun, 2012-07-08 at 14:34 -0400, Rik van Riel wrote:
>=20
> >> Do we really want to calculate the amount of CPU time used
> >> by a process, and start migrating after just one second?
> >>
> >> Or would it be ok to start migrating once a process has
> >> been scanned once or twice by the NUMA code?
> >
> > You mean, the 2-3rd time we try and migrate this task, not the memory
> > scanning thing as per Andrea, right?
>=20
> Indeed.  That way we can simply keep a flag somewhere,
> instead of iterating over the threads in a process.

Note that the code in -tip needs to iterate over all tasks in order to
test all cpus_allowed and mems_allowed masks. But we could keep a
process wide intersection of those masks around as well I guess,
updating them is a slow path anyway.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
