Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 736FD6B00EC
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:04:56 -0400 (EDT)
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p5EEgLv4013325
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 10:42:21 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p5EF4sMG122492
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:04:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p5EF4nWO018002
	for <linux-mm@kvack.org>; Tue, 14 Jun 2011 11:04:54 -0400
Date: Tue, 14 Jun 2011 20:27:06 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v4 3.0-rc2-tip 2/22]  2: uprobes: Breakground page
 replacement.
Message-ID: <20110614145706.GD4952@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
 <20110607125835.28590.25476.sendpatchset@localhost6.localdomain6>
 <1307660609.2497.1773.camel@laptop>
 <20110613085955.GD27130@linux.vnet.ibm.com>
 <1308056249.19856.34.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1308056249.19856.34.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Thomas Gleixner <tglx@linutronix.de>, Jonathan Corbet <corbet@lwn.net>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, LKML <linux-kernel@vger.kernel.org>

> > 
> > /*
> >  * NOTE:
> >  * Expect the breakpoint instruction to be the smallest size instruction for
> >  * the architecture. If an arch has variable length instruction and the
> >  * breakpoint instruction is not of the smallest length instruction
> >  * supported by that architecture then we need to modify read_opcode /
> >  * write_opcode accordingly. This would never be a problem for archs that
> >  * have fixed length instructions.
> >  */
> 
> Whoever reads comments anyway? :-)
> 
> > Do we have archs which have a breakpoint instruction which isnt of the
> > smallest instruction size for that arch. If we do have can we change the
> > write_opcode/read_opcode while we support that architecture?
> 
> Why not put a simple WARN_ON_ONCE() in there that checks the assumption?

Okay, will do.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
