Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id 5EE9A8D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 21:13:53 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20]  0: Inode based uprobes
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	<20110314163028.a05cec49.akpm@linux-foundation.org>
From: fche@redhat.com (Frank Ch. Eigler)
Date: Mon, 14 Mar 2011 21:13:25 -0400
In-Reply-To: <20110314163028.a05cec49.akpm@linux-foundation.org> (Andrew Morton's message of "Mon, 14 Mar 2011 16:30:28 -0700")
Message-ID: <y0maagxuqx6.fsf@fche.csb>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Srikar Dronamraju <srikar@linux.vnet.ibm.com>, int-list-linux-mm@kvack.orglinux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>


akpm wrote:

> [...]  How do you envisage these features actually get used?

Patch #20/20 in the set includes an ftrace-flavoured debugfs frontend.
Previous versions of the patchset included perf front-ends too, which
are probably to be seen again.

> For example, will gdb be modified?  Will other debuggers be modified
> or written? [...]

The code is not currently useful to gdb.  Perhaps ptrace or an
improved userspace ABI can get access to it in the form of a
breakpoint-management interface, though this inode+offset
style of uprobe addressing would require adaptation to the
process-virtual-address style used by debugging APIs.

- FChE

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
