Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx189.postini.com [74.125.245.189])
	by kanga.kvack.org (Postfix) with SMTP id 20BA26B004D
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:26:21 -0400 (EDT)
Received: from /spool/local
	by e5.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <srikar@linux.vnet.ibm.com>;
	Wed, 11 Apr 2012 13:26:19 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by d01dlp01.pok.ibm.com (Postfix) with ESMTP id 6581E38C8068
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:20:14 -0400 (EDT)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q3BHK9U8249584
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:20:10 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q3BHJlpJ020251
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 13:19:48 -0400
Date: Wed, 11 Apr 2012 22:42:25 +0530
From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Subject: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120411170343.GB29831@linux.vnet.ibm.com>
Reply-To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Disposition: inline
In-Reply-To: <20120411144918.GD16257@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Arnaldo Carvalho de Melo <acme@infradead.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

* Arnaldo Carvalho de Melo <acme@infradead.org> [2012-04-11 11:49:18]:

> Em Wed, Apr 11, 2012 at 07:27:42PM +0530, Srikar Dronamraju escreveu:
> > From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> > 
> > - Enhances perf to probe user space executables and libraries.
> > - Enhances -F/--funcs option of "perf probe" to list possible probe points in
> >   an executable file or library.
> > - Documents userspace probing support in perf.
> > 
> > [ Probing a function in the executable using function name  ]
> > perf probe -x /bin/zsh zfree
> > 
> > [ Probing a library function using function name ]
> > perf probe -x /lib64/libc.so.6 malloc
> > 
> > [ list probe-able functions in an executable ]
> > perf probe -F -x /bin/zsh
> > 
> > [ list probe-able functions in an library]
> > perf probe -F -x /lib/libc.so.6
> 
> Can we avoid the need for -x? I.e. we could figure out it is userspace
> and act accordingly.
> 

To list the functions in the module ipv6, we use "perf probe -F -m ipv6"
So I used the same logic to use -x for specifying executables.


This is in agreement with probepoint addition where without any
additional options would mean kernel probepoint; m option would mean
module and x option would mean user space executable. 

However if you still think we should change, do let me know.

-- 
Thanks and Regards
Srikar

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
