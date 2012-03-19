Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id DE3CD6B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:24:14 -0400 (EDT)
Message-ID: <1332170628.18960.349.camel@twins>
Subject: Re: [RFC][PATCH 10/26] mm, mpol: Make mempolicy home-node aware
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Mon, 19 Mar 2012 16:23:48 +0100
In-Reply-To: <alpine.DEB.2.00.1203191012530.17008@router.home>
References: <20120316144028.036474157@chello.nl>
	 <20120316144240.763518310@chello.nl>
	 <alpine.DEB.2.00.1203161333370.10211@router.home>
	 <1331932375.18960.237.camel@twins>
	 <alpine.DEB.2.00.1203190852380.16879@router.home>
	 <1332165959.18960.340.camel@twins>
	 <alpine.DEB.2.00.1203191012530.17008@router.home>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 2012-03-19 at 10:16 -0500, Christoph Lameter wrote:
> On Mon, 19 Mar 2012, Peter Zijlstra wrote:
>=20
> > > A HOME_NODE policy would also help to ensure that existing applicatio=
ns
> > > continue to work as expected. Given that people in the HPC industry a=
nd
> > > elsewhere have been fine tuning around the scheduler for years this i=
s a
> > > desirable goal and ensures backward compatibility.
> >
> > I really have no idea what you're saying. Existing applications that us=
e
> > mbind/set_mempolicy already continue to function exactly like before,
> > see how the new layer is below all that.
>=20
> No they wont work the same way as before. Applications may be relying on
> MPOL_DEFAULT behavior now expecting node local allocations. The home-node
> functionality would cause a difference in behavior because it would
> perform remote node allocs when a thread has been moved to a different
> socket. The changes also cause migrations that may cause additional
> latencies as well as change the location of memory in surprising ways for
> the applications

Still not sure what you're suggesting though, you argue to keep the
default what it is, this is in direct conflict with making the default
do something saner for most of the time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
