Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id D6E326B004A
	for <linux-mm@kvack.org>; Mon, 13 Jun 2011 12:50:23 -0400 (EDT)
Subject: Re: [PATCH v4 3.0-rc2-tip 4/22]  4: Uprobes: register/unregister
 probes.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <1307660606.2497.1770.camel@laptop>
References: 
	 <20110607125804.28590.92092.sendpatchset@localhost6.localdomain6>
	 <20110607125900.28590.16071.sendpatchset@localhost6.localdomain6>
	 <1307660606.2497.1770.camel@laptop>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 13 Jun 2011 12:50:19 -0400
Message-ID: <1307983819.9218.78.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Hugh Dickins <hughd@google.com>, Christoph Hellwig <hch@infradead.org>, Jonathan Corbet <corbet@lwn.net>, Thomas Gleixner <tglx@linutronix.de>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, LKML <linux-kernel@vger.kernel.org>

On Fri, 2011-06-10 at 01:03 +0200, Peter Zijlstra wrote:

> The comment in del_consumer() that says: 'drop creation ref' worries me
> and makes me thing that is the last reference around and the uprobe will
> be freed right there, which clearly cannot happen since its not yet
> removed from the RB-tree.

I agree about that comment. It scared me too, not only about the RB
tree, but the uprobe is used later in that function to drop the
write_rwsem.

I think that comment needs to be changed to something like:

/* Have caller drop the creation ref */

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
