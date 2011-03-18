Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id C29628D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:12:15 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@hack.frob.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 6/20] 6: x86: analyze instruction and
 determine fixups.
In-Reply-To: Srikar Dronamraju's message of  Saturday, 19 March 2011 00:19:22 +0530 <20110318184922.GA31152@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	<20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
	<alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
	<20110318182457.GA24048@linux.vnet.ibm.com>
	<20110318183629.2AB052C286@topped-with-meat.com>
	<20110318184922.GA31152@linux.vnet.ibm.com>
Message-Id: <20110318191047.4BAF12C183@topped-with-meat.com>
Date: Fri, 18 Mar 2011 12:10:47 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> So we rewrite the copy of instruction (stored in XOL) such that it
> accesses its memory operand indirectly thro a scratch register.
> The contents of the scratch register are stored before singlestep and
> restored later.

I see.  That should work fine in principle, assuming you use a register
that is not otherwise involved, of course.  I hope you arrange to restore
the register if the copied instruction is never run because of a signal or
suchlike.  In that case, it's important that the signal context get the
original register and original PC rather than the fiddled state for running
the copy.  Likewise, if anyone is inspecting the registers right after the
step.


Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
