Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 0340C6B002D
	for <linux-mm@kvack.org>; Mon, 28 Nov 2011 09:14:05 -0500 (EST)
Message-ID: <1322489609.2921.132.camel@twins>
Subject: Re: [PATCH v7 3.2-rc2 9/30] uprobes: Background page replacement.
From: Peter Zijlstra <peterz@infradead.org>
Date: Mon, 28 Nov 2011 15:13:29 +0100
In-Reply-To: <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com>
	 <20111118110823.10512.74338.sendpatchset@srdronam.in.ibm.com>
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On Fri, 2011-11-18 at 16:38 +0530, Srikar Dronamraju wrote:
> +/**
> + * is_bkpt_insn - check if instruction is breakpoint instruction.
> + * @insn: instruction to be checked.
> + * Default implementation of is_bkpt_insn
> + * Returns true if @insn is a breakpoint instruction.
> + */
> +bool __weak is_bkpt_insn(u8 *insn)
> +{
> +       return (insn[0] =3D=3D UPROBES_BKPT_INSN);
>  }=20

This seems wrong, UPROBES_BKPT_INSN basically defined to be of
uprobe_opcode_t type, not u8.

So:

bool __weak is_bkpt_insn(uprobe_opcode_t *insn)
{
	return *insn =3D=3D UPROBE_BKPT_INSN;
}

seems like the right way to write this.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
