Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id E96F7900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 12:47:54 -0400 (EDT)
Subject: Re: [PATCH v3 2.6.39-rc1-tip 13/26] 13: uprobes: get the
 breakpoint address.
From: Peter Zijlstra <peterz@infradead.org>
In-Reply-To: <20110401143507.15455.87968.sendpatchset@localhost6.localdomain6>
References: 
	 <20110401143223.15455.19844.sendpatchset@localhost6.localdomain6>
	 <20110401143507.15455.87968.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Date: Mon, 18 Apr 2011 18:47:22 +0200
Message-ID: <1303145242.32491.887.camel@twins>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On Fri, 2011-04-01 at 20:05 +0530, Srikar Dronamraju wrote:
> +/**
> + * uprobes_get_bkpt_addr - compute address of bkpt given post-bkpt regs
> + * @regs: Reflects the saved state of the task after it has hit a breakp=
oint
> + * instruction.
> + * Return the address of the breakpoint instruction.
> + */
> +unsigned long uprobes_get_bkpt_addr(struct pt_regs *regs)
> +{
> +       return instruction_pointer(regs) - UPROBES_BKPT_INSN_SIZE;
> +}=20

This assumes the breakpoint instruction is trap like, not fault like, is
that true for all architectures?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
