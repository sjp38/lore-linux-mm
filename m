Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx175.postini.com [74.125.245.175])
	by kanga.kvack.org (Postfix) with SMTP id D25576B0044
	for <linux-mm@kvack.org>; Fri, 30 Mar 2012 09:14:12 -0400 (EDT)
Date: Fri, 30 Mar 2012 15:05:30 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/2] uprobes/core: counter to optimize probe hits.
Message-ID: <20120330130530.GA16319@redhat.com>
References: <20120321180811.22773.5801.sendpatchset@srdronam.in.ibm.com> <20120321180826.22773.57531.sendpatchset@srdronam.in.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120321180826.22773.57531.sendpatchset@srdronam.in.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>

On 03/21, Srikar Dronamraju wrote:
>
> + * uprobe_munmap() decrements the count if
> + * 	- it sees a underlying breakpoint, (via is_swbp_at_addr)
> + * 	  (Subsequent unregister_uprobe wouldnt find the breakpoint
> + * 	  unless a uprobe_mmap kicks in, since the old vma would be
> + * 	  dropped just after uprobe_munmap.)
> + *
> + * register_uprobe increments the count if:
> + * 	- it successfully adds a breakpoint.
> + *
> + * unregister_uprobe decrements the count if:

Cosmetic nit, register_uprobe/unregister_uprobe do not exist.
uprobe_register/unregister.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
