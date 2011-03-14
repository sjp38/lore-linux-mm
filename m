Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with SMTP id 332748D003E
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 11:29:11 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
 replacement.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 14 Mar 2011 11:29:06 -0400
Message-ID: <1300116546.9910.107.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2011-03-14 at 19:04 +0530, Srikar Dronamraju wrote:
> +/*
> + * Most architectures can use the default versions of @read_opcode(),
> + * @set_bkpt(), @set_orig_insn(), and @is_bkpt_insn();
> + *
> + * @set_ip:
> + *     Set the instruction pointer in @regs to @vaddr.
> + * @analyze_insn:
> + *     Analyze @user_bkpt->insn.  Return 0 if @user_bkpt->insn is an
> + *     instruction you can probe, or a negative errno (typically -%EPERM)
> + *     otherwise. Determine what sort of

sort of ... what?

-- Steve

> + * @pre_xol:
> + * @post_xol:
> + *     XOL-related fixups @post_xol() (and possibly @pre_xol()) will need
> + *     to do for this instruction, and annotate @user_bkpt accordingly.
> + *     You may modify @user_bkpt->insn (e.g., the x86_64 port does this
> + *     for rip-relative instructions).
> + */ 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
