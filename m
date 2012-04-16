Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx144.postini.com [74.125.245.144])
	by kanga.kvack.org (Postfix) with SMTP id 6B1F76B00F9
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 11:35:03 -0400 (EDT)
Date: Mon, 16 Apr 2012 17:34:08 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [PATCH 2/6] uprobes: introduce is_swbp_at_addr_fast()
Message-ID: <20120416153408.GA8852@redhat.com>
References: <20120405222024.GA19154@redhat.com> <20120405222106.GB19166@redhat.com> <1334570935.28150.25.camel@twins> <20120416144457.GA7018@redhat.com> <1334588109.28150.59.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1334588109.28150.59.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

On 04/16, Peter Zijlstra wrote:
>
> Can't we 'optimize' read_opcode() by doing the pagefault_disable() +
> __copy_from_user_inatomic() optimistically before going down the whole
> gup()+lock+kmap path?

Unlikely, the task is not current.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
