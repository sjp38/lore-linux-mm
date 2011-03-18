Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 1BCA38D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:36:32 -0400 (EDT)
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
From: Roland McGrath <roland@hack.frob.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 6/20] 6: x86: analyze instruction and
 determine fixups.
In-Reply-To: Srikar Dronamraju's message of  Friday, 18 March 2011 23:54:57 +0530 <20110318182457.GA24048@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	<20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
	<alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
	<20110318182457.GA24048@linux.vnet.ibm.com>
Message-Id: <20110318183629.2AB052C286@topped-with-meat.com>
Date: Fri, 18 Mar 2011 11:36:29 -0700 (PDT)
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> handle_riprel_insn() returns 0 if the instruction is not rip-relative
> returns 1 if its rip-relative but can use XOL slots.
> returns -1 if its rip-relative but cannot use XOL.
> 
> We dont see any instructions that are rip-relative and cannot use XOL.
> so the check and return are redundant and I will remove that in the next
> patch.

How is that?  You can only adjust a rip-relative instruction correctly if
the instruction copy is within 2GB of the original target address, which
cannot be presumed to always be the case in user address space layout
(unlike the kernel).

Thanks,
Roland

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
