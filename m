Date: Mon, 11 Aug 2008 10:36:25 -0400 (EDT)
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
In-Reply-To: <48A04AEE.8090606@linux-foundation.org>
Message-ID: <alpine.DEB.1.10.0808111033320.29861@gandalf.stny.rr.com>
References: <1218388447-5578-1-git-send-email-eduard.munteanu@linux360.ro>  <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>  <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>  <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro>
  <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>  <48A046F5.2000505@linux-foundation.org>  <1218463774.7813.291.camel@penberg-laptop>  <48A048FD.30909@linux-foundation.org> <1218464177.7813.293.camel@penberg-laptop>
 <48A04AEE.8090606@linux-foundation.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Christoph Lameter <cl@linux-foundation.org>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Mon, 11 Aug 2008, Christoph Lameter wrote:

> Pekka Enberg wrote:
> 
> > The function call is supposed to go away when we convert kmemtrace to
> > use Mathieu's markers but I suppose even then we have a problem with
> > inlining?
> 
> The function calls are overwritten with NOPs? Or how does that work?

I believe in the latest version they are just a variable test. But when 
Mathieu's immediate code makes it in (which it is in linux-tip), we will 
be overwriting the conditionals with nops (Mathieu, correct me if I'm 
wrong here).

But the calls themselves are done in the unlikely branch. This is 
important, as Mathieu stated in previous thread. The reason is that all 
the stack setup for the function call is also in the unlikely branch, and 
the normal fast path does not take a hit for the function call setup.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
