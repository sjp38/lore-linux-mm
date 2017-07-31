Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wr0-f197.google.com (mail-wr0-f197.google.com [209.85.128.197])
	by kanga.kvack.org (Postfix) with ESMTP id 825AC6B04C7
	for <linux-mm@kvack.org>; Mon, 31 Jul 2017 15:49:48 -0400 (EDT)
Received: by mail-wr0-f197.google.com with SMTP id x43so48065797wrb.9
        for <linux-mm@kvack.org>; Mon, 31 Jul 2017 12:49:48 -0700 (PDT)
Received: from mout.gmx.net (mout.gmx.net. [212.227.15.18])
        by mx.google.com with ESMTPS id u17si6053233wra.219.2017.07.31.12.49.47
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 31 Jul 2017 12:49:47 -0700 (PDT)
Message-ID: <1501530579.9118.43.camel@gmx.de>
Subject: Re: [PATCH 3/3] mm/sched: memdelay: memory health interface for
 systems and workloads
From: Mike Galbraith <efault@gmx.de>
Date: Mon, 31 Jul 2017 21:49:39 +0200
In-Reply-To: <20170731184142.GA30943@cmpxchg.org>
References: <20170727153010.23347-1-hannes@cmpxchg.org>
	 <20170727153010.23347-4-hannes@cmpxchg.org>
	 <20170729091055.GA6524@worktop.programming.kicks-ass.net>
	 <20170730152813.GA26672@cmpxchg.org>
	 <20170731083111.tgjgkwge5dgt5m2e@hirez.programming.kicks-ass.net>
	 <20170731184142.GA30943@cmpxchg.org>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>, Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, kernel-team@fb.com

On Mon, 2017-07-31 at 14:41 -0400, Johannes Weiner wrote:
>=20
> Adding an rq counter for tasks inside memdelay sections should be
> straight-forward as well (except for maybe the migration cost of that
> state between CPUs in ttwu that Mike pointed out).

What I pointed out should be easily eliminated (zero use case).
=C2=A0
> That leaves the question of how to track these numbers per cgroup at
> an acceptable cost. The idea for a tree of cgroups is that walltime
> impact of delays at each level is reported for all tasks at or below
> that level. E.g. a leave group aggregates the state of its own tasks,
> the root/system aggregates the state of all tasks in the system; hence
> the propagation of the task state counters up the hierarchy.

The crux of the biscuit is where exactly the investment return lies.
=C2=A0Gathering of these numbers ain't gonna be free, no matter how hard yo=
u
try, and you're plugging into paths where every cycle added is made of
userspace hide.

	-Mike

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
