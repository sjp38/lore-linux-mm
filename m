Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4C1CB6B0089
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 20:17:30 -0500 (EST)
Subject: Re: [RFC][PATCH 2/2] [PATCH 2/2] tracing/slub: Move kmalloc
 tracepoint out of inline code
From: Steven Rostedt <rostedt@goodmis.org>
In-Reply-To: <4CEDB53E.5000203@cn.fujitsu.com>
References: <20101124212333.808256210@goodmis.org>
	 <20101124212717.468748477@goodmis.org>  <4CEDB53E.5000203@cn.fujitsu.com>
Content-Type: text/plain; charset="ISO-8859-15"
Date: Wed, 24 Nov 2010 20:17:26 -0500
Message-ID: <1290647846.30543.707.camel@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: Li Zefan <lizf@cn.fujitsu.com>
Cc: linux-kernel@vger.kernel.org, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Peter Zijlstra <peterz@infradead.org>, Frederic Weisbecker <fweisbec@gmail.com>, Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, Richard Kennedy <richard@rsk.demon.co.uk>
List-ID: <linux-mm.kvack.org>

On Thu, 2010-11-25 at 09:00 +0800, Li Zefan wrote:
> Cc: Richard Kennedy <richard@rsk.demon.co.uk>
> 
> Steven Rostedt wrote:
> > From: Steven Rostedt <srostedt@redhat.com>
> > 
> > The tracepoint for kmalloc is in the slub inlined code which causes
> > every instance of kmalloc to have the tracepoint.
> > 
> > This patch moves the tracepoint out of the inline code to the
> > slub C file (and to page_alloc), which removes a large number of
> > inlined trace points.
> > 
> >   objdump -dr vmlinux.slub| grep 'jmpq.*<trace_kmalloc' |wc -l
> > 375
> >   objdump -dr vmlinux.slub.patched| grep 'jmpq.*<trace_kmalloc' |wc -l
> > 2
> > 
> > This also has a nice impact on size.
> >    text	   data	    bss	    dec	    hex	filename
> > 7050424	1961068	2482688	11494180	 af6324	vmlinux.slub
> > 6979599	1944620	2482688	11406907	 ae0e3b	vmlinux.slub.patched
> > 
> > Siged-off-by: Steven Rostedt <rostedt@goodmis.org>
> 
> See this patch from Richard: :)
> 
> http://marc.info/?l=linux-kernel&m=128765337729262&w=2
> 
> But he only touched slub.

Hehe, and I forgot about it ;-) I notice the large number of kmalloc
tracepoints while analyzing the jump label code, and wanted to do
something about it.

I also see that Pekka replied saying that he applied it.

Pekka, want to take my first patch?

-- Steve


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
