Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx187.postini.com [74.125.245.187])
	by kanga.kvack.org (Postfix) with SMTP id 429516B00EA
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 07:31:14 -0400 (EDT)
Message-ID: <1332156655.18960.297.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 19 Mar 2012 12:30:55 +0100
In-Reply-To: <1332155527.18960.292.camel@twins>
References: <20120316144028.036474157@chello.nl>
	 <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 12:12 +0100, Peter Zijlstra wrote:
> Also, if you go scan memory, you need some storage -- see how aa grows
> struct page, sure he wants to move that storage some place else, but the
> memory overhead is still there -- this means less memory to actually do
> useful stuff in (it also probably means more cache-misses since his
> proposed shadow array in pgdat is someplace else).=20

Going by the sizes in aa's patch, that's 96M of my 16G box gone. That
puts HPC people in a rather awkward position of having to choose between
more memory and slightly smarter kernel. I'm thinking they're going to
opt for going the way they are now (hard affinity/userspace balancers)
and use the extra memory.

This even though typical MPI implementations use the multi-process
scheme, so the simple home-node approach I used works just fine for
them.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
