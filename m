Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BD7D28D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 21:36:18 -0400 (EDT)
Date: Tue, 15 Mar 2011 02:35:55 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
In-Reply-To: <y0maagxuqx6.fsf@fche.csb>
Message-ID: <alpine.LFD.2.00.1103150224260.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314163028.a05cec49.akpm@linux-foundation.org> <y0maagxuqx6.fsf@fche.csb>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Frank Ch. Eigler" <fche@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Srikar Dronamraju <srikar@linux.vnet.ibm.com>, int-list-linux-mm@kvack.orglinux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 14 Mar 2011, Frank Ch. Eigler wrote:
> akpm wrote:
> 
> > [...]  How do you envisage these features actually get used?
> 
> Patch #20/20 in the set includes an ftrace-flavoured debugfs frontend.

And you really think that:

# cd /sys/kernel/debug/tracing/

# cat /proc/`pgrep  zsh`/maps | grep /bin/zsh | grep r-xp
00400000-0048a000 r-xp 00000000 08:03 130904 /bin/zsh

# objdump -T /bin/zsh | grep -w zfree
0000000000446420 g    DF .text  0000000000000012  Base        zfree

# echo 'p /bin/zsh:0x46420 %ip %ax' > uprobe_events

# cat uprobe_events
p:uprobes/p_zsh_0x46420 /bin/zsh:0x0000000000046420

> TODO: Documentation/trace/uprobetrace.txt

without a reasonable documentation how to use that is a brilliant
argument?

> Previous versions of the patchset included perf front-ends too, which
> are probably to be seen again.

Ahh, probably. What does that mean?

     And if that probably happens, what interface is that supposed to
     use?

	The above magic wrapped into perf ?

	Or some sensible implementation ?

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
