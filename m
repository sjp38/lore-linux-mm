Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx205.postini.com [74.125.245.205])
	by kanga.kvack.org (Postfix) with SMTP id 282B46B0044
	for <linux-mm@kvack.org>; Mon, 23 Apr 2012 17:26:38 -0400 (EDT)
Date: Mon, 23 Apr 2012 23:25:36 +0200
From: Oleg Nesterov <oleg@redhat.com>
Subject: Re: [RFC 0/6] uprobes: kill uprobes_srcu/uprobe_srcu_id
Message-ID: <20120423212536.GA8700@redhat.com>
References: <1334571419.28150.30.camel@twins> <20120416214707.GA27639@redhat.com> <1334916861.2463.50.camel@laptop> <20120420183718.GA2236@redhat.com> <1335165240.28150.89.camel@twins> <20120423072445.GC8357@linux.vnet.ibm.com> <1335166842.28150.92.camel@twins> <20120423172957.GA29708@redhat.com> <1335208690.2463.84.camel@laptop> <20120423205049.GA7831@redhat.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120423205049.GA7831@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

forgot to mention,

On 04/23, Oleg Nesterov wrote:
>
> Just it seems to me there are to many "details"
> we should discuss to make the filtering reasonable.

And so far we assumed that consumer->filter() is "stable" and never
changes its mind.

Perhaps this is fine, but I am not sure. May we need need some
interface to add/del the task. Probably not, but unregister + register
doesn't look very convenient and can miss a hit.

> Yes, and probably this makes sense for handler_chain(). Although otoh
> I do not really understand what this filter buys us at this point.

But if we change the rules so that ->filter() or ->handler() itself can
return the "please remove this bp from ->mm" then perhaps it makes more
sense for the filtering. Again, not sure.

Oleg.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
