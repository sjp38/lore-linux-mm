Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx132.postini.com [74.125.245.132])
	by kanga.kvack.org (Postfix) with SMTP id B2B3E6B004A
	for <linux-mm@kvack.org>; Mon, 19 Mar 2012 09:54:03 -0400 (EDT)
Date: Mon, 19 Mar 2012 08:53:57 -0500 (CDT)
From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC][PATCH 10/26] mm, mpol: Make mempolicy home-node aware
In-Reply-To: <1331932375.18960.237.camel@twins>
Message-ID: <alpine.DEB.2.00.1203190852380.16879@router.home>
References: <20120316144028.036474157@chello.nl> <20120316144240.763518310@chello.nl> <alpine.DEB.2.00.1203161333370.10211@router.home> <1331932375.18960.237.camel@twins>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Dan Smith <danms@us.ibm.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Fri, 16 Mar 2012, Peter Zijlstra wrote:

> > > Note that the tsk_home_node() policy has Migrate-on-Fault enabled to
> > > facilitate efficient on-demand memory migration.
> >
> > The numa hierachy is already complex. Could we avoid adding another layer
> > by adding a MPOL_HOME_NODE and make that the default?
>
> Not sure that's really a win, the behaviour would be the same we just
> have to implement another policy, which is likely more code.

A HOME_NODE policy would also help to ensure that existing applications
continue to work as expected. Given that people in the HPC industry and
elsewhere have been fine tuning around the scheduler for years this is a
desirable goal and ensures backward compatibility.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
