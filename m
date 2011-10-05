Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id CD4FD9400BF
	for <linux-mm@kvack.org>; Wed,  5 Oct 2011 12:34:38 -0400 (EDT)
Date: Wed, 5 Oct 2011 18:29:46 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 10/26]   x86: Set instruction pointer.
Message-ID: <20111005162946.GA1366@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120148.25326.96997.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120148.25326.96997.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On 09/20, Srikar Dronamraju wrote:
>
> --- a/arch/x86/include/asm/uprobes.h
> +++ b/arch/x86/include/asm/uprobes.h
> @@ -39,4 +39,5 @@ struct uprobe_arch_info {};
>  #endif
>  struct uprobe;
>  extern int analyze_insn(struct task_struct *tsk, struct uprobe *uprobe);
> +extern void set_instruction_pointer(struct pt_regs *regs, unsigned long vaddr);

Well, this is minor, but we already have instruction_pointer_set().

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
