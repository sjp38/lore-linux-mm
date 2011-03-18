Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 23BE78D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:56:12 -0400 (EDT)
Received: from d01dlp01.pok.ibm.com (d01dlp01.pok.ibm.com [9.56.224.56])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2IIVe1j001860
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:31:40 -0400
Received: from d01relay03.pok.ibm.com (d01relay03.pok.ibm.com [9.56.227.235])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 0C8CC38C8038
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:55:59 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay03.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2IIu2r8275980
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:56:02 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2IIu1Id006849
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 15:56:02 -0300
Date: Sat, 19 Mar 2011 00:19:22 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 6/20] 6: x86: analyze instruction and
 determine fixups.
Message-ID: <20110318184922.GA31152@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133507.27435.71382.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151529130.2787@localhost6.localdomain6>
 <20110318182457.GA24048@linux.vnet.ibm.com>
 <20110318183629.2AB052C286@topped-with-meat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20110318183629.2AB052C286@topped-with-meat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Roland McGrath <roland@hack.frob.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Roland McGrath <roland@hack.frob.com> [2011-03-18 11:36:29]:

> > handle_riprel_insn() returns 0 if the instruction is not rip-relative
> > returns 1 if its rip-relative but can use XOL slots.
> > returns -1 if its rip-relative but cannot use XOL.
> > 
> > We dont see any instructions that are rip-relative and cannot use XOL.
> > so the check and return are redundant and I will remove that in the next
> > patch.
> 
> How is that?  You can only adjust a rip-relative instruction correctly if
> the instruction copy is within 2GB of the original target address, which
> cannot be presumed to always be the case in user address space layout
> (unlike the kernel).
> 

So we rewrite the copy of instruction (stored in XOL) such that it
accesses its memory operand indirectly thro a scratch register.
The contents of the scratch register are stored before singlestep and
restored later.

Can you please tell us if this doesnt work?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
