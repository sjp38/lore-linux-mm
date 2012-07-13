Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx151.postini.com [74.125.245.151])
	by kanga.kvack.org (Postfix) with SMTP id 6316B6B005A
	for <linux-mm@kvack.org>; Fri, 13 Jul 2012 10:19:14 -0400 (EDT)
Date: Fri, 13 Jul 2012 09:19:06 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [PATCH 20/40] autonuma: alloc/free/init mm_autonuma
In-Reply-To: <20120712181738.GA1349@cmpxchg.org>
Message-ID: <alpine.DEB.2.00.1207130918320.24910@router.home>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com> <1340888180-15355-21-git-send-email-aarcange@redhat.com> <20120630051217.GG3975@localhost.localdomain> <20120712180828.GL20382@redhat.com> <20120712181738.GA1349@cmpxchg.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Johannes Weiner <hannes@cmpxchg.org>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 12 Jul 2012, Johannes Weiner wrote:

> On Thu, Jul 12, 2012 at 08:08:28PM +0200, Andrea Arcangeli wrote:
> > On Sat, Jun 30, 2012 at 01:12:18AM -0400, Konrad Rzeszutek Wilk wrote:
> > > On Thu, Jun 28, 2012 at 02:56:00PM +0200, Andrea Arcangeli wrote:
> > > > This is where the mm_autonuma structure is being handled. Just like
> > > > sched_autonuma, this is only allocated at runtime if the hardware the
> > > > kernel is running on has been detected as NUMA. On not NUMA hardware
> > >
> > > I think the correct wording is "non-NUMA", not "not NUMA".
> >
> > That sounds far too easy to me, but I've no idea what's the right is here.
>
> UMA?
>
> Single-node hardware?

Lets be simple and stay with non-NUMA.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
