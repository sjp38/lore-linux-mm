Return-Path: <owner-linux-mm@kvack.org>
Received: from mail172.messagelabs.com (mail172.messagelabs.com [216.82.254.3])
	by kanga.kvack.org (Postfix) with SMTP id 1326C6B002D
	for <linux-mm@kvack.org>; Fri,  7 Oct 2011 13:07:56 -0400 (EDT)
Date: Fri, 7 Oct 2011 19:03:47 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH v5 3.1.0-rc4-tip 3/26]   Uprobes: register/unregister
	probes.
Message-ID: <20111007170347.GB32319@redhat.com>
References: <20110920115938.25326.93059.sendpatchset@srdronam.in.ibm.com> <20110920120022.25326.35868.sendpatchset@srdronam.in.ibm.com> <20111003124640.GA25811@redhat.com> <20111005170420.GB28250@linux.vnet.ibm.com> <20111005185008.GA8107@redhat.com> <20111006065125.GC17591@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20111006065125.GC17591@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andrew Morton <akpm@linux-foundation.org>

On 10/06, Srikar Dronamraju wrote:
>
> * Oleg Nesterov <oleg@redhat.com> [2011-10-05 20:50:08]:
>
> yes we might be doing an unnecessary __register_uprobe() but because it
> raced with unregister_uprobe() and got the lock, we would avoid doing a
> __unregister_uprobe().
>
> However I am okay to move the lock before del_consumer().

To me this looks a bit "safer" even if currently __register is idempotent.

But,

> Please let me
> know how you prefer this.

No, no, Srikar. Please do what you prefer. You are the author.

And btw I forgot to mention that initially I wrongly thought this is buggy.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
