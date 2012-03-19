Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx136.postini.com [74.125.245.136])
	by kanga.kvack.org (Postfix) with SMTP id C6A1E6B010D
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 16:43:15 -0400 (EDT)
Date: Mon, 19 Mar 2012 15:43:09 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 00/26] sched/numa
In-Reply-To: <20120319202846.GA26555@gmail.com>
Message-ID: <alpine.DEB.2.00.1203191536390.23632@router.home>
References: <20120316144028.036474157@chello.nl> <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins> <20120319130401.GI24602@redhat.com> <1332164371.18960.339.camel@twins> <20120319142046.GP24602@redhat.com> <alpine.DEB.2.00.1203191513110.23632@router.home>
 <20120319202846.GA26555@gmail.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Avi Kivity <avi@redhat.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 Mar 2012, Ingo Molnar wrote:

> > I wonder how we can verify that the automatic migration
> > schemes are a real benefit to the application? We have a
> > history of developing a kernel that decreases in performance
> > as development proceeds. How can we make sure that these
> > schemes are actually beneficial overall for all loads and do
> > not cause regressions elsewhere? [...]
>
> The usual way?

Which is merge after a couple of benchmarks and then deal with the
regressions for a couple of years?

Patch verification occurs in an artificial bubble of software run/known by
kernel developers. It can take years before the code is exposed to
real life situations.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
