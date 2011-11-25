Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 14B2E6B0080
	for <linux-mm@kvack.org>; Fri, 25 Nov 2011 09:28:46 -0500 (EST)
Received: from j77219.upc-j.chello.nl ([24.132.77.219] helo=dyad.programming.kicks-ass.net)
	by casper.infradead.org with esmtpsa (Exim 4.76 #1 (Red Hat Linux))
	id 1RTwlf-0004nS-7g
	for linux-mm@kvack.org; Fri, 25 Nov 2011 14:28:43 +0000
Subject: Re: [PATCH v7 3.2-rc2 9/30] uprobes: Background page replacement.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 25 Nov 2011 15:29:24 +0100
Message-ID: <1322231365.2535.6.camel@laptop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:38 +0530, Srikar Dronamraju wrote:
> +       /* poke the new insn in, ASSUMES we don't cross page boundary */
> +       vaddr &= ~PAGE_MASK;
> +       memcpy(vaddr_new + vaddr, &opcode, uprobe_opcode_sz);

I still don't get why you don't simply write something like:

BUG_ON(vaddr + uprobe_opcode_size >= PAGE_SIZE);

That's as descriptive as the comment and actually does something if
someone got it wrong, instead of silently corrupting crap.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
