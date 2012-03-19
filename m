Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id E47716B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 11:16:46 -0400 (EDT)
Date: Mon, 19 Mar 2012 10:16:41 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 10/26] mm, mpol: Make mempolicy home-node aware
In-Reply-To: <1332165959.18960.340.camel@twins>
Message-ID: <alpine.DEB.2.00.1203191012530.17008@router.home>
References: <20120316144028.036474157@chello.nl> <20120316144240.763518310@chello.nl> <alpine.DEB.2.00.1203161333370.10211@router.home> <1331932375.18960.237.camel@twins> <alpine.DEB.2.00.1203190852380.16879@router.home> <1332165959.18960.340.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Mon, 19 Mar 2012, Peter Zijlstra wrote:

> > A HOME_NODE policy would also help to ensure that existing applications
> > continue to work as expected. Given that people in the HPC industry and
> > elsewhere have been fine tuning around the scheduler for years this is a
> > desirable goal and ensures backward compatibility.
>
> I really have no idea what you're saying. Existing applications that use
> mbind/set_mempolicy already continue to function exactly like before,
> see how the new layer is below all that.

No they wont work the same way as before. Applications may be relying on
MPOL_DEFAULT behavior now expecting node local allocations. The home-node
functionality would cause a difference in behavior because it would
perform remote node allocs when a thread has been moved to a different
socket. The changes also cause migrations that may cause additional
latencies as well as change the location of memory in surprising ways for
the applications

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
