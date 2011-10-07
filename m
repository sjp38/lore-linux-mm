Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 1DA336B002F
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 14:35:05 -0400 (EDT)
Date: Fri, 7 Oct 2011 20:31:02 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 13/26]   x86: define a x86 specific
	exception notifier.
Message-ID: <20111007183102.GB1655@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120238.25326.71868.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20110920120238.25326.71868.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andi Kleen <andi@firstfloor.org>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On 09/20, Srikar Dronamraju wrote:
>
> +int uprobe_exception_notify(struct notifier_block *self,
> +				       unsigned long val, void *data)
> +{
> +	struct die_args *args = data;
> +	struct pt_regs *regs = args->regs;
> +	int ret = NOTIFY_DONE;
> +
> +	/* We are only interested in userspace traps */
> +	if (regs && !user_mode_vm(regs))
> +		return NOTIFY_DONE;
> +
> +	switch (val) {
> +	case DIE_INT3:
> +		/* Run your handler here */
> +		if (uprobe_bkpt_notifier(regs))
> +			ret = NOTIFY_STOP;
> +		break;

OK, but I simply can't understand do_int3(). It uses DIE_INT3 or
DIE_TRAP depending on CONFIG_KPROBES.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
