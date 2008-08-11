Received: from toip4.srvr.bell.ca ([209.226.175.87])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080811183331.TTJJ29750.tomts13-srv.bellnexxia.net@toip4.srvr.bell.ca>
          for <linux-mm@kvack.org>; Mon, 11 Aug 2008 14:33:31 -0400
Date: Mon, 11 Aug 2008 14:28:31 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080811182831.GC32207@Krystal>
References: <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop> <48A048FD.30909@linux-foundation.org> <1218464177.7813.293.camel@penberg-laptop> <48A04AEE.8090606@linux-foundation.org> <alpine.DEB.1.10.0808111033320.29861@gandalf.stny.rr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <alpine.DEB.1.10.0808111033320.29861@gandalf.stny.rr.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Steven Rostedt <rostedt@goodmis.org>
Cc: Christoph Lameter <cl@linux-foundation.org>, Pekka Enberg <penberg@cs.helsinki.fi>, Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

* Steven Rostedt (rostedt@goodmis.org) wrote:
> 
> On Mon, 11 Aug 2008, Christoph Lameter wrote:
> 
> > Pekka Enberg wrote:
> > 
> > > The function call is supposed to go away when we convert kmemtrace to
> > > use Mathieu's markers but I suppose even then we have a problem with
> > > inlining?
> > 
> > The function calls are overwritten with NOPs? Or how does that work?
> 
> I believe in the latest version they are just a variable test. But when 
> Mathieu's immediate code makes it in (which it is in linux-tip), we will 
> be overwriting the conditionals with nops (Mathieu, correct me if I'm 
> wrong here).
> 

The current immediate values in tip does a load immediate, test, branch,
which removes the cost of the memory load. We will try to get gcc
support to be able to declare patchable static jump sites, which could
be patched with NOPs when disabled. But that will probably not happen
"now".

Mathieu

> But the calls themselves are done in the unlikely branch. This is 
> important, as Mathieu stated in previous thread. The reason is that all 
> the stack setup for the function call is also in the unlikely branch, and 
> the normal fast path does not take a hit for the function call setup.
> 
> -- Steve
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
