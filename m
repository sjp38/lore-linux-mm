Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx126.postini.com [74.125.245.126])
	by kanga.kvack.org (Postfix) with SMTP id 004CD6B0071
	for <linux-mm@kvack.org>; Thu,  5 Jul 2012 08:18:50 -0400 (EDT)
Received: from dhcp-089-099-019-018.chello.nl ([89.99.19.18] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1Sml1F-0006xP-50
	for linux-mm@kvack.org; Thu, 05 Jul 2012 12:18:49 +0000
Subject: Re: [PATCH 09/40] autonuma: introduce kthread_bind_node()
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
In-Reply-To: <20120704231425.GP25743@redhat.com>
References: <1340888180-15355-1-git-send-email-aarcange@redhat.com>
	 <1340888180-15355-10-git-send-email-aarcange@redhat.com>
	 <20120630045013.GB3975@localhost.localdomain>
	 <20120704231425.GP25743@redhat.com>
Content-Type: text/plain; charset="UTF-8"
Date: Thu, 05 Jul 2012 14:18:30 +0200
Message-ID: <1341490710.19870.31.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: Konrad Rzeszutek Wilk <konrad@darnok.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Hillf Danton <dhillf@gmail.com>, Dan Smith <danms@us.ibm.com>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Paul Turner <pjt@google.com>, Suresh Siddha <suresh.b.siddha@intel.com>, Mike Galbraith <efault@gmx.de>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Lai Jiangshan <laijs@cn.fujitsu.com>, Bharata B Rao <bharata.rao@gmail.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Srivatsa Vaddagiri <vatsa@linux.vnet.ibm.com>, Christoph Lameter <cl@linux.com>, Alex Shi <alex.shi@intel.com>, Mauricio Faria de Oliveira <mauricfo@linux.vnet.ibm.com>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, Don Morris <don.morris@hp.com>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

On Thu, 2012-07-05 at 01:14 +0200, Andrea Arcangeli wrote:
> I can change it to _GPL, drop the EXPORT_SYMBOL or move it inside the
> autonuma code, let me know what you prefer. If I hear nothing I won't
> make changes. 

If I find even a single instance of PF_THREAD_BOUND in your next posting
I'll simply not look at it at all.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
