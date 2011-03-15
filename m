Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id D46DE8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 20:23:01 -0400 (EDT)
Date: Tue, 15 Mar 2011 01:22:24 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
In-Reply-To: <20110314234754.GP2499@one.firstfloor.org>
Message-ID: <alpine.LFD.2.00.1103150114590.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314163028.a05cec49.akpm@linux-foundation.org> <20110314234754.GP2499@one.firstfloor.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 15 Mar 2011, Andi Kleen wrote:

> > IOW, I'm trying to get an understanding of how you expect this feature
> > will actually become useful to end users - the kernel patch is only
> > part of the story.
> 
> One user would be systemtap for user tracing as I understand. Systemtap has a 
> userbase (at least I use it, although not for user tracing)

That's a brilliant reason to drop it right away. systemtap is the
least of our worries.
 
> Right now lots of distros apply ugly patchkits to handle this instead,
> which is not good (tm).

s/lots of distros/some enterprise distros where the management still
believes that this is a valuable feature add/

You deliberately skipped the first part of akpms question:

> How do you envisage these features actually get used?  For example,
> will gdb be modified?  Will other debuggers be modified or written?

How about answering this question first _BEFORE_ advertising
systemtap?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
