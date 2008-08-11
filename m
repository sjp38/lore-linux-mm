Received: from toip3.srvr.bell.ca ([209.226.175.86])
          by tomts16-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080811182939.FPML1723.tomts16-srv.bellnexxia.net@toip3.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 11 Aug 2008 14:29:39 -0400
Date: Mon, 11 Aug 2008 14:29:38 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080811182938.GD32207@Krystal>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop> <48A048FD.30909@linux-foundation.org> <alpine.DEB.1.10.0808111027370.29861@gandalf.stny.rr.com> <48A04EC2.1080302@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <48A04EC2.1080302@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Steven Rostedt <rostedt@goodmis.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

* Christoph Lameter (cl@linux-foundation.org) wrote:
> Steven Rostedt wrote:
> 
> > The kmemtrace_mark_alloc_node itself is an inline function, which calls 
> > another inline function "trace_mark" which is designed to test a 
> > read_mostly variable, and will do an "unlikely" jmp if the variable is 
> > set (which it is when tracing is enabled), to the actual function call.
> > 
> > There should be no extra function calls when this is configured on but 
> > tracing disabled. We try very hard to keep the speed of the tracer as 
> > close to a non tracing kernel as possible when tracing is disabled.
> 
> Makes sense. But then we have even more code bloat because of the tests that
> are inserted in all call sites of kmalloc.
> 

The long-term goal is to turn the tests into NOPs, but only once we get
gcc support.

Mathieu

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
