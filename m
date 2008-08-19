Received: from toip6.srvr.bell.ca ([209.226.175.125])
          by tomts13-srv.bellnexxia.net
          (InterMail vM.5.01.06.13 201-253-122-130-113-20050324) with ESMTP
          id <20080819181654.CUTU29750.tomts13-srv.bellnexxia.net@toip6.srvr.bell.ca>
          for <linux-mm@kvack.org>; Tue, 19 Aug 2008 14:16:54 -0400
Date: Tue, 19 Aug 2008 14:16:53 -0400
From: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Subject: Re: [PATCH 1/5] Revert "kmemtrace: fix printk format warnings"
Message-ID: <20080819181652.GA29757@Krystal>
References: <1219167807-5407-1-git-send-email-eduard.munteanu@linux360.ro> <Pine.LNX.4.64.0808191049260.7877@shark.he.net> <20080819175440.GA5435@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
In-Reply-To: <20080819175440.GA5435@localhost>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: "Randy.Dunlap" <rdunlap@xenotime.net>, penberg@cs.helsinki.fi, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mpm@selenic.com, tglx@linutronix.de, rostedt@goodmis.org, cl@linux-foundation.org, tzanussi@gmail.com
List-ID: <linux-mm.kvack.org>

* Eduard - Gabriel Munteanu (eduard.munteanu@linux360.ro) wrote:
> On Tue, Aug 19, 2008 at 10:51:32AM -0700, Randy.Dunlap wrote:
> > On Tue, 19 Aug 2008, Eduard - Gabriel Munteanu wrote:
> > 
> > > This reverts commit 79cf3d5e207243eecb1c4331c569e17700fa08fa.
> > > 
> > > The reverted commit, while it fixed printk format warnings, it resulted in
> > > marker-probe format mismatches. Another approach should be used to fix
> > > these warnings.
> > 
> > Such as what?
> > 
> > Can marker probes be fixed instead?
> > 
> > After seeing & fixing lots of various warnings in the last few days,
> > I'm thinking that people don't look at/heed warnings nowadays.  Sad.
> > Maybe there are just so many that they are lost in the noise.
> 
> Hi,
> 
> Check the next patch in the series, it provides the alternate fix.
> I favor this approach more because it involves fewer changes and we
> don't have to use things like "%zu" (which make data type size less
> apparent).
> 

Question :

Is this kmemtrace marker meant to be exposed to userspace ?

I suspect not. In all case, not directly. I expect in-kernel probes to
be connected on these markers which will get the arguments they need,
and maybe access the inner data structures. Anyhow, tracepoints should
be used for that, not markers. You can later put markers in the probes
which are themselves connected to tracepoints.

Tracepoints = in-kernel tracing API.

Markers = Data-formatting tracing API, meant to export the data either
to user-space in text or binary format.

See

http://git.kernel.org/?p=linux/kernel/git/compudj/linux-2.6-lttng.git;a=shortlog

tracepoint-related patches.

Mathieu

> 
> 	Cheers,
> 	Eduard
> 

-- 
Mathieu Desnoyers
OpenPGP key fingerprint: 8CD5 52C3 8E3C 4140 715F  BA06 3F25 A8FE 3BAE 9A68

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
