Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id F373C6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 08:22:59 -0400 (EDT)
Date: Thu, 5 Jul 2012 14:21:29 +0200
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: Re: [PATCH 09/40] autonuma: introduce kthread_bind_node()
Message-ID: <20120705122129.GX25743@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
 <1340888180-15355-10-git-send-email-aarcange@redhat.com>
 <20120630045013.GB3975@localhost.localdomain>
 <20120704231425.GP25743@redhat.com>
 <1341490710.19870.31.camel@laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1341490710.19870.31.camel@laptop>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, Jul 05, 2012 at 02:18:30PM +0200, Peter Zijlstra wrote:
> On Thu, 2012-07-05 at 01:14 +0200, Andrea Arcangeli wrote:
> > I can change it to _GPL, drop the EXPORT_SYMBOL or move it inside the
> > autonuma code, let me know what you prefer. If I hear nothing I won't
> > make changes. 
> 
> If I find even a single instance of PF_THREAD_BOUND in your next posting
> I'll simply not look at it at all.

Thanks for the info, that's one more reason to keep it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
