Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id B00998D003A
	for <linux-mm@kvack.org>; Mon, 14 Mar 2011 14:22:45 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20]  3: uprobes: Breakground page
 replacement.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110314172439.GO24254@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
	 <1300117137.9910.110.camel@gandalf.stny.rr.com>
	 <20110314172439.GO24254@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Mon, 14 Mar 2011 14:22:42 -0400
Message-ID: <1300126962.9910.128.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Mon, 2011-03-14 at 22:54 +0530, Srikar Dronamraju wrote:
> > 
> > I'm confused by the above comment and code. You state we are only
> > interested text pages mapped read-only, but then if the page is mapped
> > read/exec we exit out? It is fine if it is anything but READ/EXEC.
> 
> You are right, it should have been
>         if ((vma->vm_flags & (VM_READ|VM_WRITE|VM_EXEC|VM_SHARED)) !=
>                                         (VM_READ|VM_EXEC))
>                 goto put_out;
> 
> 
Golden rule #12: When the comments do not match the code, they probably
are both wrong ;)

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
