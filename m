Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 95FA48D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 13:47:46 -0400 (EDT)
Subject: Re: [PATCH v2 2.6.38-rc8-tip 5/20] 5: Uprobes: register/unregister
 probes.
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <20110315171536.GA24254@linux.vnet.ibm.com>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6>
	 <20110314133454.27435.81020.sendpatchset@localhost6.localdomain6>
	 <alpine.LFD.2.00.1103151439400.2787@localhost6.localdomain6>
	 <20110315171536.GA24254@linux.vnet.ibm.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Tue, 15 Mar 2011 13:47:42 -0400
Message-ID: <1300211262.9910.295.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Thomas Gleixner <tglx@linutronix.de>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Linux-mm <linux-mm@kvack.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Christoph Hellwig <hch@infradead.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Oleg Nesterov <oleg@redhat.com>, LKML <linux-kernel@vger.kernel.org>, SystemTap <systemtap@sources.redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, Roland McGrath <roland@hack.frob.com>, Andi Kleen <andi@firstfloor.org>, Andrew Morton <akpm@linux-foundation.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 2011-03-15 at 22:45 +0530, Srikar Dronamraju wrote:
> > > +   }
> > > +   list_for_each_entry_safe(mm, tmpmm, &tmp_list, uprobes_list) {
> > > +           down_read(&mm->mmap_sem);
> > > +           if (!install_uprobe(mm, uprobe))
> > > +                   ret = 0;
> > 
> > Installing it once is success ?
> 
> This is a little tricky. My intention was to return success even if one
> install is successful. If we return error, then the caller can go
> ahead and free the consumer. Since we return success if there are
> currently no processes that have mapped this inode, I was tempted to
> return success on atleast one successful install.

What about an all or nothing approach. If one fails, remove all that
were installed, and give up.

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
