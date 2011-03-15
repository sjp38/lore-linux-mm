Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with ESMTP id EABBF8D0039
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:46:31 -0400 (EDT)
Received: from canuck.infradead.org ([2001:4978:20e::1])
	by bombadil.infradead.org with esmtps (Exim 4.72 #1 (Red Hat Linux))
	id 1PzaCL-0002TZ-Ok
	for linux-mm@kvack.org; Tue, 15 Mar 2011 19:46:30 +0000
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by canuck.infradead.org with esmtpsa (Exim 4.72 #1 (Red Hat Linux))
	id 1PzaCJ-0004c9-Kg
	for linux-mm@kvack.org; Tue, 15 Mar 2011 19:46:27 +0000
Subject: Re: [PATCH v2 2.6.38-rc8-tip 4/20] 4: uprobes: Adding and remove a
 uprobe in a rb tree.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <alpine.LFD.2.00.1103151916120.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133444.27435.50684.sendpatchset@localhost6.localdomain6>
	 <alpine.LFD.2.00.1103151425060.2787@localhost6.localdomain6>
	 <20110315173041.GB24254@linux.vnet.ibm.com>
	 <alpine.LFD.2.00.1103151916120.2787@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 15 Mar 2011 20:48:19 +0100
Message-ID: <1300218499.2250.12.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul
 E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 20:22 +0100, Thomas Gleixner wrote:
> I am not sure if its a good idea to walk the tree
> > as and when the tree is changing either because of a insertion or
> > deletion of a probe.
> 
> I know that you cannot walk the tree lockless except you would use
> some rcu based container for your probes. 

You can in fact combine a seqlock, rb-trees and RCU to do lockless
walks.

  https://lkml.org/lkml/2010/10/20/160

and

  https://lkml.org/lkml/2010/10/20/437

But doing that would be an optimization best done once we get all this
working nicely.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
