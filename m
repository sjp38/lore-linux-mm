Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
From: Matt Mackall <mpm@selenic.com>
In-Reply-To: <20080812152954.GB5973@localhost>
References: <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro>
	 <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro>
	 <48A046F5.2000505@linux-foundation.org>
	 <1218463774.7813.291.camel@penberg-laptop>
	 <48A048FD.30909@linux-foundation.org>
	 <1218464177.7813.293.camel@penberg-laptop>
	 <48A04AEE.8090606@linux-foundation.org>
	 <1218464557.7813.295.camel@penberg-laptop>
	 <20080812152954.GB5973@localhost>
Content-Type: text/plain
Date: Tue, 12 Aug 2008 21:09:59 -0500
Message-Id: <1218593399.7576.428.camel@calx>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Cc: Pekka Enberg <penberg@cs.helsinki.fi>, Christoph Lameter <cl@linux-foundation.org>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Tue, 2008-08-12 at 18:29 +0300, Eduard - Gabriel Munteanu wrote:
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

Did we ever see size(1) numbers for kernels with and without this
support? I'm still a bit worried about adding branches to such a popular
inline. Simply multiplying the branch test by the number of locations is
pretty substantial, never mind the unlikely part of the branch.

-- 
Mathematics is the supreme nostalgia of our time.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
