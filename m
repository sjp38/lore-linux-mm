Received: from toip5.srvr.bell.ca ([209.226.175.88])
          by tomts25-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080812154336.IZYB1557.tomts25-srv.bellnexxia.net@toip5.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 12 Aug 2008 11:43:36 -0400
Date: Tue, 12 Aug 2008 11:43:34 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080812154334.GA18581@Krystal>
References: <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop> <48A048FD.30909@linux-foundation.org> <1218464177.7813.293.camel@penberg-laptop> <48A04AEE.8090606@linux-foundation.org> <1218464557.7813.295.camel@penberg-laptop> <20080812152954.GB5973@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20080812152954.GB5973@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

* Eduard - Gabriel Munteanu (eduard.munteanu@linux360.ro) wrote:
> On Mon, Aug 11, 2008 at 05:22:37PM +0300, Pekka Enberg wrote:
> > On Mon, 2008-08-11 at 09:21 -0500, Christoph Lameter wrote:
> > > Pekka Enberg wrote:
> > > 
> > > > The function call is supposed to go away when we convert kmemtrace to
> > > > use Mathieu's markers but I suppose even then we have a problem with
> > > > inlining?
> > > 
> > > The function calls are overwritten with NOPs? Or how does that work?
> > 
> > I have no idea. Mathieu, Eduard?
> 
> Yes, the code is patched at runtime. But AFAIK markers already provide
> this stuff (called "immediate values"). Mathieu's tracepoints also do
> it. But it's not available on all arches. x86 and x86-64 work as far as
> I remember.
> 

The markers present in mainline kernel does not use immediate values.
However, immediate values in tip does implement a load
immediate/test/branch for x86, x86_64 and powerpc. I also have support
for sparc64 in my lttng tree.

Mathieu


-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
