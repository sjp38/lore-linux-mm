Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx120.postini.com [74.125.245.120])
	by kanga.kvack.org (Postfix) with SMTP id 0A0B86B0113
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 08:36:39 -0400 (EDT)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Mon, 16 Apr 2012 06:36:38 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id CE1303E40058
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:35:47 -0600 (MDT)
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3GCZbMt122706
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:35:41 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3GCZan0010370
	for <linux-mm@kvack.org>; Mon, 16 Apr 2012 06:35:37 -0600
Date: Mon, 16 Apr 2012 17:57:37 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120416122737.GB25464@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
 <20120411181727.GK16257@infradead.org>
 <4F864BB3.3090405@hitachi.com>
 <20120412140751.GM16257@infradead.org>
 <20120412151037.GC21587@linux.vnet.ibm.com>
 <4F87C76B.10001@hitachi.com>
 <20120414011330.GC31880@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120414011330.GC31880@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

> 
> > > Another case 
> > > perf probe do_fork clone_flags now looks for variable clone_flags in
> > > kernel function do_fork.
> 
> > > But if we allow to trace perf probe zsh zfree; then 
> > > 'perf probe do_fork clone_flags' should it check for do_fork executable
> > > or not? If it does check and finds one, and searches for clone_flags
> > > function and doesnt find, then should it continue with searching the
> > > kernel?
> 
> > Agree. I'd like to suggest you to start with only full path support,
> > and see, how we can handle abbreviations :)
> 
> Agreed, I was just making usability suggestions.
> 
> Those can be implemented later, if we agree they ease the tool use.
> 

I have just made a prototype for guessing the target when -m and -x
options arent passed. That still uses the absolute path for now.

I was trying to see if we can identify the module by the short name by
using kernel_get_module_path(). However kernel_get_module_path() needs
init_vmlinux() to be called before. Since init_vmlinux() cant be called
more than once and init_vmlinux gets called later, I thought calling it
here wasnt good option. Wanted to see if we could open /proc/modules
and then match the module name.  But again, I wasnt sure how to handle
offline modules.  

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
