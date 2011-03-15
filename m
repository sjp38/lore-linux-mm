Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id E73208D003A
	for <linux-mm@kvack.org>; Tue, 15 Mar 2011 07:03:45 -0400 (EDT)
Date: Tue, 15 Mar 2011 12:02:45 +0100 (CET)
From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH v2 2.6.38-rc8-tip 0/20] 0: Inode based uprobes
In-Reply-To: <20110315052133.GT24254@linux.vnet.ibm.com>
Message-ID: <alpine.LFD.2.00.1103151158220.2787@localhost6.localdomain6>
References: <20110314133403.27435.7901.sendpatchset@localhost6.localdomain6> <20110314163028.a05cec49.akpm@linux-foundation.org> <y0maagxuqx6.fsf@fche.csb> <alpine.LFD.2.00.1103150224260.2787@localhost6.localdomain6>
 <20110315052133.GT24254@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, int-list-linux-mm@kvack.orglinux-mm@kvack.org, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Steven Rostedt <rostedt@goodmis.org>, Arnaldo Carvalho de Melo <acme@infradead.org>, Linus Torvalds <torvalds@linux-foundation.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Christoph Hellwig <hch@infradead.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Andi Kleen <andi@firstfloor.org>, Oleg Nesterov <oleg@redhat.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, SystemTap <systemtap@sources.redhat.com>, LKML <linux-kernel@vger.kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>

On Tue, 15 Mar 2011, Srikar Dronamraju wrote:
> > > TODO: Documentation/trace/uprobetrace.txt
> > 
> > without a reasonable documentation how to use that is a brilliant
> > argument?
> 
> We had a fairly decent documentation for uprobes and
> uprobetracer. But that had to be changed with  the change in
> underlying design of uprobes infrastructure. Since uprobetrace is one
> the user interface, I plan to document it soon. However it would be
> great if we had inputs on how we should be designing the syscall.

Ok.
 
> > 	Or some sensible implementation ?
> 
> Would syscall based perf probe implementation count as a sensible
> implementation? My current plan was to code up the perf probe for

Yes.

> uprobes and then draft a proposal for how the syscall should look. 
> There are still some areas on how we should be allowing the
> filter, and what restrictions we should place on the syscall
> defined handler. I would like to hear from you and others on your
> ideas for the same. If you have ideas on doing it other than using a
> syscall then please do let me know about the same.

I don't think that anything else than a proper syscall interface is
going to work out.

> I know that getting the user interface right is very important.
> However I think it kind of depends on what the infrastructure can
> provide too. So if we can decide on the kernel ABI and the
> underlying design (i.e can we use replace_page() based background page
> replacement, Are there issues with the Xol slot based mechanism that
> we are using, etc), we can work towards providing a stable User ABI that
> even normal users can use. For now I am concentrating on getting the
> underlying infrastructure correct.

Fair enough. I'll go through the existing patchset and comment there.

Thanks,

	tglx

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
