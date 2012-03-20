Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx196.postini.com [74.125.245.196])
	by kanga.kvack.org (Postfix) with SMTP id BAC026B011C
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 20:05:54 -0400 (EDT)
Received: by dadv6 with SMTP id v6so13298612dad.14
        for <linux-mm@kvack.org>; Mon, 19 Mar 2012 17:05:54 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20120319202846.GA26555@gmail.com>
References: <20120316144028.036474157@chello.nl> <4F670325.7080700@redhat.com>
 <1332155527.18960.292.camel@twins> <20120319130401.GI24602@redhat.com>
 <1332164371.18960.339.camel@twins> <20120319142046.GP24602@redhat.com>
 <alpine.DEB.2.00.1203191513110.23632@router.home> <20120319202846.GA26555@gmail.com>
From: Linus Torvalds <torvalds@linux-foundation.org>
Date: Mon, 19 Mar 2012 17:05:33 -0700
Message-ID: <CA+55aFwa-81x2Dysk8WS8ez2WkYSbaQDyQvpH0qE7fGJgxTbUQ@mail.gmail.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Christoph Lameter <cl@linux.com>, Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, Mar 19, 2012 at 1:28 PM, Ingo Molnar <mingo@kernel.org> wrote:
>
> That having said PeterZ's numbers showed some pretty good
> improvement for the streams workload:
>
> =A0before: 512.8M
> =A0after: 615.7M
>
> i.e. a +20% improvement on a not very heavily NUMA box.

Well, streams really isn't a very interesting benchmark. It's the
traditional single-threaded cpu-only thing that just accesses things
linearly, and I'm not convinced the numbers should be taken to mean
anything at all.

The HPC people want to multi-thread things these days, and "cpu/memory
affinity" is a lot less clear then.

So I can easily imagine that the performance improvement is real, but
I really don't think "streams improves by X %" is all that
interesting. Are there any more relevant loads that actually matter to
people that we could show improvement on?

                     Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
