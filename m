Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx182.postini.com [74.125.245.182])
	by kanga.kvack.org (Postfix) with SMTP id 2D9D26B00FD
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:03:28 -0400 (EDT)
Message-ID: <1332187387.18960.389.camel@twins>
Subject: Re: [RFC][PATCH 00/26] sched/numa
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 21:03:07 +0100
In-Reply-To: <4F672384.1030601@redhat.com>
References: <20120316144028.036474157@chello.nl>
	   <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>
	  <4F671B90.3010209@redhat.com> <1332158992.18960.316.camel@twins>
	 <4F672384.1030601@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Avi Kivity <avi@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 14:16 +0200, Avi Kivity wrote:
> > Afaik we do not use dma engines for memory migration.=20
>=20
> We don't, but I think we should.=20

ISTR we (the community) had this discussion once. I also seem to
remember the general consensus being that DMA engines would mostly
likely not be worth the effort, although I can't really recall the
specifics.

Esp. for 4k pages the setup of the offload will likely be more expensive
than actually doing the memcpy.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
