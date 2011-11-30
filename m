Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 947CD6B0047
	for <linux-mm@kvack.org>; Wed, 30 Nov 2011 14:03:05 -0500 (EST)
Date: Wed, 30 Nov 2011 19:57:51 +0100
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v7 3.2-rc2 8/30] x86: analyze instruction and determine
	fixups.
Message-ID: <20111130185751.GA8160@redhat.com>
References: <20111118110631.10512.73274.sendpatchset@srdronam.in.ibm.com> <20111118110808.10512.72719.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111118110808.10512.72719.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Roland McGrath <roland@hack.frob.com>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Arnaldo Carvalho de Melo <acme@infradead.org>, Anton Arapov <anton@redhat.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Stephen Wilson <wilsons@start.ca>

On 11/18, Srikar Dronamraju wrote:
>
> +static void handle_riprel_insn(struct mm_struct *mm, struct uprobe *uprobe,
> +							struct insn *insn)
> +{
> [...snip...]
> +	if (insn->immediate.nbytes) {
> +		cursor++;
> +		memmove(cursor, cursor + insn->displacement.nbytes,
> +						insn->immediate.nbytes);
> +	}
> +	return;
> +}

Of course I don not understand this code. But it seems that it can
rewrite uprobe->insn ?

If yes, don't we need to save the original insn for unregister_uprobe?

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
