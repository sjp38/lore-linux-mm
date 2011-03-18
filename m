Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id 98BFC8D0039
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:59:56 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e3.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2IIdPnr018438
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:39:29 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id D6C3E6E8036
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:59:54 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2IIxsxe231508
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:59:54 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2IIxrG0018212
	for <linux-mm@kvack.org>; Fri, 18 Mar 2011 14:59:54 -0400
Date: Sat, 19 Mar 2011 00:23:14 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
Message-ID: <20110318185314.GB24048@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6>
 <20110315171536.GA24254@linux.vnet.ibm.com>
 <1300211262.9910.295.camel@gandalf.stny.rr.com>
 <1300211411.2203.290.camel@twins>
 <20110315180423.GA10429@linux.vnet.ibm.com>
 <1300212949.2203.324.camel@twins>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <1300212949.2203.324.camel@twins>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

> > 
> > One of the install_uprobe could be failing because the process was
> > almost exiting, something like there was no mm->owner. Also lets
> > assume that the first few install_uprobes go thro and the last
> > install_uprobe fails. There could be breakpoint hits corresponding to
> > the already installed uprobes that get displayed. i.e all
> > breakpoint hits from the first install_uprobe to the time we detect a
> > failed a install_uprobe and revert all inserted breakpoints will be
> > shown as being captured.
> 
> I think you can gracefully deal with the exit case and simply ignore
> that one. But you cannot let arbitrary installs fail and still report
> success, that gives very weak and nearly useless semantics.

If there are more than one instance of a process running and if one
instance of a process has a probe thro ptrace, install_uprobe would fail
for that process with -EEXIST since we dont want to probe locations that
have breakpoints already. Should we then act similar to the exit case,
do we also deal gracefully?

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
