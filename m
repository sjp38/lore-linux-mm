Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx113.postini.com [74.125.245.113])
	by kanga.kvack.org (Postfix) with SMTP id B02F36B004A
	for <linux-mm@kvack.org>; Wed, 11 Apr 2012 14:17:44 -0400 (EDT)
Date: Wed, 11 Apr 2012 15:17:28 -0300
From: Arnaldo Carvalho de Melo <acme@infradead.org>
Subject: Re: [PATCH] perf/probe: Provide perf interface for uprobes
Message-ID: <20120411181727.GK16257@infradead.org>
References: <20120411135742.29198.45061.sendpatchset@srdronam.in.ibm.com>
 <20120411144918.GD16257@infradead.org>
 <20120411170343.GB29831@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20120411170343.GB29831@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Linus Torvalds <torvalds@linux-foundation.org>, Ananth N Mavinakayanahalli <ananth@in.ibm.com>, Jim Keniston <jkenisto@linux.vnet.ibm.com>, LKML <linux-kernel@vger.kernel.org>, Linux-mm <linux-mm@kvack.org>, Oleg Nesterov <oleg@redhat.com>, Andi Kleen <andi@firstfloor.org>, Christoph Hellwig <hch@infradead.org>, Steven Rostedt <rostedt@goodmis.org>, Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>, Thomas Gleixner <tglx@linutronix.de>, Anton Arapov <anton@redhat.com>

Em Wed, Apr 11, 2012 at 10:42:25PM +0530, Srikar Dronamraju escreveu:
> * Arnaldo Carvalho de Melo <acme@infradead.org> [2012-04-11 11:49:18]:
> > Em Wed, Apr 11, 2012 at 07:27:42PM +0530, Srikar Dronamraju escreveu:
> > > From: Srikar Dronamraju <srikar@linux.vnet.ibm.com>
> > > 
> > > - Enhances perf to probe user space executables and libraries.
> > > - Enhances -F/--funcs option of "perf probe" to list possible probe points in
> > >   an executable file or library.
> > > - Documents userspace probing support in perf.
> > > 
> > > [ Probing a function in the executable using function name  ]
> > > perf probe -x /bin/zsh zfree
> > 
> > Can we avoid the need for -x? I.e. we could figure out it is userspace
> > and act accordingly.
> 
> To list the functions in the module ipv6, we use "perf probe -F -m ipv6"
> So I used the same logic to use -x for specifying executables.
> 
> This is in agreement with probepoint addition where without any
> additional options would mean kernel probepoint; m option would mean
> module and x option would mean user space executable. 
> 
> However if you still think we should change, do let me know.

Yeah, if one needs to disambiguate, sure, use these keywords, but for
things like:

$ perf probe /lib/libc.so.6 malloc

I think it is easy to figure out it is userspace. I.e. some regex would
figure it out.

Anyway this can be done in a follow up patch.

- Arnaldo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
