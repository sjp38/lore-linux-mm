Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 5C2626B005D
	for <linux-mm@kvack.org>; Tue, 29 May 2012 14:35:41 -0400 (EDT)
Date: Tue, 29 May 2012 20:35:16 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 13/35] autonuma: add page structure fields
Message-ID: <20120529183516.GO21339@redhat.com>
References: <1337965359-29725-1-git-send-email-aarcange@redhat.com>
 <1337965359-29725-14-git-send-email-aarcange@redhat.com>
 <1338297385.26856.74.camel@twins>
 <20120529163849.GF21339@redhat.com>
 <4FC4FD51.2080001@redhat.com>
 <1338310613.26856.139.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1338310613.26856.139.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>

On Tue, May 29, 2012 at 06:56:53PM +0200, Peter Zijlstra wrote:
> On Tue, 2012-05-29 at 12:46 -0400, Rik van Riel wrote:
> > > I don't think it's too great, memcg uses for half of that and yet
> > > nobody is booting with cgroup_disable=memory even on not-NUMA servers
> > > with less RAM.
> 
> Right, it was such a hit we had to disable that by default on RHEL6.

CONFIG_CGROUP_MEM_RES_CTLR is =y, do you mean it's set to
cgroup_disable=memory by default in grub? I didn't notice that.

If a certain amount of users is passing cgroup_disable=memory at boot
because they don't need the feature, well that's perfectly reasonable
and the way it should be. That's why such an option exists and why I
also provided a noautonuma parameter for the same reason.

> Right, hnaz did great work there, but wasn't there still some few pieces
> of the shadow page frame left? ISTR LSF/MM talk of moving the last few
> bits into the regular page frame, taking the word that became available
> through: fc9bb8c768 ("mm: Rearrange struct page").

memcg diet topic is there for a long time, they started working on it
more than 1 year ago, I'm currently referring to current upstream
(maybe 1 week ago old).

But this is normal, first you focus on the algorithm, then you worry
how to optimize the implementation to reduce the memory usage without
altering the runtime (well, without altering it too much at least...).

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
