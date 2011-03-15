Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with ESMTP id 521A88D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:13:48 -0400 (EDT)
Received: from d01dlp02.pok.ibm.com (d01dlp02.pok.ibm.com [9.56.224.85])
	by e8.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p2FDsWc5026907
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 09:54:33 -0400
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id 2F1FC6E803E
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:13:46 -0400 (EDT)
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p2FIDjLd2314484
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 14:13:45 -0400
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p2FIDh0G031969
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 15:13:45 -0300
Date: Tue, 15 Mar 2011 23:37:43 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 3/20] 3: uprobes: Breakground page
 replacement.
Message-ID: <20110315180743.GD24254@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
 <20110314133433.27435.49566.sendpatchset@localhost6.localdomain6>
 <alpine.LFD.2.00.1103151206430.2787@localhost6.localdomain6>
 <20110315175048.GC24254@linux.vnet.ibm.com>
 <alpine.LFD.2.00.1103151902020.2787@localhost6.localdomain6>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.1103151902020.2787@localhost6.localdomain6>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Thomas Gleixner <tglx@linutronix.de>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Christoph Hellwig <hch@infradead.org>, Andi Kleen <andi@firstfloor.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, SystemTap <systemtap@sources.redhat.com>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

* Thomas Gleixner <tglx@linutronix.de> [2011-03-15 19:03:44]:

> On Tue, 15 Mar 2011, Srikar Dronamraju wrote:
> 
> > * Thomas Gleixner <tglx@linutronix.de> [2011-03-15 14:22:09]:
> > 
> > > On Mon, 14 Mar 2011, Srikar Dronamraju wrote:
> > > > +/*
> > > > + * Called with tsk->mm->mmap_sem held (either for read or write and
> > > > + * with a reference to tsk->mm
> > > 
> > > Hmm, why is holding it for read sufficient?
> > 
> > We are not adding a new vma to the mm; but just replacing a page with
> > another after holding the locks for the pages. Existing routines
> > doing close to similar things like the
> > access_process_vm/get_user_pages seem to be taking the read_lock. Do
> > you see a resaon why readlock wouldnt suffice?
> 
> No, I just was confused by the comment. Probably should have asked why
> you want to call it write locked.

We no more call it write locked. So we can drop the reference to
write lock.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
