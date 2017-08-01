Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 518176B04E3
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 22:23:27 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id m80so797994wmd.4
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 19:23:27 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id 74si233226wma.57.2017.07.31.19.23.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 19:23:26 -0700 (PDT)
Message-ID: <1501554199.5269.22.camel@gmx.de>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
From: Mike Galbraith <efault@gmx.de>
Date: Tue, 01 Aug 2017 04:23:19 +0200
In-Reply-To: <20170731203839.GA5162@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
	 <20170727153010.23347-4-hannes@cmpxchg.org>
	 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
	 <20170730152813.GA26672@cmpxchg.org>
	 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
	 <20170731184142.GA30943@cmpxchg.org> <1501530579.9118.43.camel@gmx.de>
	 <20170731203839.GA5162@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, 2017-07-31 at 16:38 -0400, Johannes Weiner wrote:
> On Mon, Jul 31, 2017 at 09:49:39PM +0200, Mike Galbraith wrote:
> > On Mon, 2017-07-31 at 14:41 -0400, Johannes Weiner wrote:
> > >=20
> > > Adding an rq counter for tasks inside memdelay sections should be
> > > straight-forward as well (except for maybe the migration cost of that
> > > state between CPUs in ttwu that Mike pointed out).
> >=20
> > What I pointed out should be easily eliminated (zero use case).
>=20
> How so?

I was thinking along the lines of=C2=A0schedstat_enabled().

> > > That leaves the question of how to track these numbers per cgroup at
> > > an acceptable cost. The idea for a tree of cgroups is that walltime
> > > impact of delays at each level is reported for all tasks at or below
> > > that level. E.g. a leave group aggregates the state of its own tasks,
> > > the root/system aggregates the state of all tasks in the system; henc=
e
> > > the propagation of the task state counters up the hierarchy.
> >=20
> > The crux of the biscuit is where exactly the investment return lies.
> > =C2=A0Gathering of these numbers ain't gonna be free, no matter how har=
d you
> > try, and you're plugging into paths where every cycle added is made of
> > userspace hide.
>=20
> Right. But how to implement it sanely and optimize for cycles, and
> whether we want to default-enable this interface are two separate
> conversations.
>=20
> It makes sense to me to first make the implementation as lightweight
> on cycles and maintainability as possible, and then worry about the
> cost / benefit defaults of the shipped Linux kernel afterwards.
>=20
> That goes for the purely informative userspace interface, anyway. The
> easily-provoked thrashing livelock I have described in the email to
> Andrew is a different matter. If the OOM killer requires hooking up to
> this metric to fix it, it won't be optional. But the OOM code isn't
> part of this series yet, so again a conversation best had later, IMO.

If that "the many must pay a toll to save the few" conversation ever
happens, just recall me registering my boo/hiss in advance. =C2=A0I don't
have to feel guilty about not liking the idea of making donations to
feed the poor starving proggies ;-)

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
