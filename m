Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 7C4006B007E
	for <linux-mm@kvack.org>; Tue, 27 Mar 2012 04:40:14 -0400 (EDT)
Message-ID: <1332837595.16159.208.camel@twins>
Subject: Re: [PATCH 11/39] autonuma: CPU follow memory algorithm
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date: Tue, 27 Mar 2012 10:39:55 +0200
In-Reply-To: <20120326203951.GZ5906@redhat.com>
References: <1332783986-24195-1-git-send-email-aarcange@redhat.com>
	 <1332783986-24195-12-git-send-email-aarcange@redhat.com>
	 <1332786353.16159.173.camel@twins> <4F70C365.8020009@redhat.com>
	 <20120326194435.GW5906@redhat.com>
	 <CA+55aFwk0Etg_UhoZcKsfFJ7PQNLdQ58xxXiwcA-jemuXdZCZQ@mail.gmail.com>
	 <20120326203951.GZ5906@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Hillf Danton <dhillf@gmail.com>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Dan Smith <danms@us.ibm.com>, Paul Turner <pjt@google.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Rik van Riel <riel@redhat.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, linux-mm@kvack.org, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, Bharata B Rao <bharata.rao@gmail.com>, Thomas Gleixner <tglx@linutronix.de>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org

On Mon, 2012-03-26 at 22:39 +0200, Andrea Arcangeli wrote:

> > No, you can't just say that it's limited to some large constant, and th=
us
> > the same as O(1).
>=20
> I pointed out it is O(1) just because if we use the O notation we may
> as well do the math right about it.

I think you have a fundamental mis-understanding of the concepts here.
You do not get to fill in n for whatever specific instance of the
problem you have.

The traveling salesman problem can be solved in O(n!), simply because
you know your route will not be larger than 10 houses doesn't mean you
can say your algorithm will be O(10!) and thus O(1).

That's simply not how it works.

You can talk pretty much anything down to O(1) that way. Take an
algorithm that is O(n) in the number of tasks, since you know you have a
pid-space constraint of 30bits you can never have more than 2^30 (aka
1Gi) tasks, hence your algorithm is O(2^30) aka O(1).

> I also would welcome people who knows the scheduler so much better
> than me to rewrite or fix it as they like it.

Again, you seem unclear on how things work, you want this nonsense, you
get to write it.

I am most certainly not going to fix your mess as I completely disagree
with the approach taken.

> I probably wasn't clear enough, but I already implicitly meant it
> shall be optimized further later.

You're in fact very unclear. You post patches without the RFC tag,
meaning you think they're ready to be considered. You write huge
misleading comments instead of /* XXX crap, needs fixing */.

Also, I find your language to be overly obtuse and hard to parse, but
that could be my fault, we're both non-native speakers.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
