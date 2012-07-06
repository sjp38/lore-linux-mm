Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id DD71C6B0073
	for <linux-mm@kvack.org>; Fri,  6 Jul 2012 11:01:34 -0400 (EDT)
Message-ID: <1341586848.7709.54.camel@twins>
Subject: Re: [RFC][PATCH 02/26] mm, mpol: Remove NUMA_INTERLEAVE_HIT
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Fri, 06 Jul 2012 17:00:48 +0200
In-Reply-To: <CAH9JG2U-_RzDQ9TgjXWSBFjscCKn0oKp1mhvOsRVoxR7hsSxHA@mail.gmail.com>
References: <20120316144028.036474157@chello.nl>
	 <20120316144240.234456258@chello.nl>
	 <CAH9JG2U-_RzDQ9TgjXWSBFjscCKn0oKp1mhvOsRVoxR7hsSxHA@mail.gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Kyungmin Park <kmpark@infradead.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E.
 McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 2012-07-06 at 23:54 +0900, Kyungmin Park wrote:
> >  static struct zonelist *policy_zonelist(gfp_t gfp, struct mempolicy *p=
olicy,
> >         int nd)
> >  {
> >         switch (policy->mode) {
> > +       case MPOL_INTERLEAVE:
> > +               nd =3D interleave_nodes(policy);
> Jut nitpick,
> Original code also uses the 'unsigned nid' but now it assigned
> 'unsigned nid' to 'int nd' at here. does it right?=20

node id is generally signed, we use -1 as a special value indicating no
node preference in a number of places. Not sure why it was unsigned
here. Also I think even SGI isn't anywhere near 2^31 nodes.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
