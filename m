Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx162.postini.com [74.125.245.162])
	by kanga.kvack.org (Postfix) with SMTP id 9BAD36B004A
	for <linux-mm@kvack.org>; Tue, 20 Mar 2012 06:53:04 -0400 (EDT)
Message-ID: <4F686163.40509@redhat.com>
Date: Tue, 20 Mar 2012 12:52:19 +0200
From: Avi Kivity <avi@redhat.com>
MIME-Version: 1.0
Subject: Re: [RFC][PATCH 00/26] sched/numa
References: <20120316144028.036474157@chello.nl>     <4F670325.7080700@redhat.com> <1332155527.18960.292.camel@twins>    <4F671B90.3010209@redhat.com> <1332158992.18960.316.camel@twins>   <4F672384.1030601@redhat.com> <1332187387.18960.389.camel@twins>  <4F685960.4080904@redhat.com> <1332240525.18960.403.camel@twins>
In-Reply-To: <1332240525.18960.403.camel@twins>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On 03/20/2012 12:48 PM, Peter Zijlstra wrote:
> On Tue, 2012-03-20 at 12:18 +0200, Avi Kivity wrote:
> > On 03/19/2012 10:03 PM, Peter Zijlstra wrote:
> > > On Mon, 2012-03-19 at 14:16 +0200, Avi Kivity wrote:
> > > > > Afaik we do not use dma engines for memory migration. 
> > > > 
> > > > We don't, but I think we should. 
> > >
> > > ISTR we (the community) had this discussion once. I also seem to
> > > remember the general consensus being that DMA engines would mostly
> > > likely not be worth the effort, although I can't really recall the
> > > specifics.
> > >
> > > Esp. for 4k pages the setup of the offload will likely be more expensive
> > > than actually doing the memcpy.
> > 
> > If you're copying a page, yes.  If you're copying a large vma, the
> > per-page setup cost is likely to be very low.
> > 
> > Especially if you're copying across nodes.
>
> But wouldn't you then have to wait for the entire copy to complete
> before accessing any of the memory? That sounds like a way worse latency
> hit than the per-page lazy-migrate.

You use the dma engine for eager copying, not on demand.

-- 
error compiling committee.c: too many arguments to function

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
