Received: by qb-out-1314.google.com with SMTP id e11so4530749qbc.4
        for <linux-mm@kvack.org>; Tue, 12 Aug 2008 08:32:40 -0700 (PDT)
Date: Tue, 12 Aug 2008 18:29:54 +0300
From: Eduard - Gabriel Munteanu <eduard.munteanu@linux360.ro>
Subject: Re: [PATCH 4/5] kmemtrace: SLUB hooks.
Message-ID: <20080812152954.GB5973@localhost>
References: <1218388447-5578-2-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-3-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-4-git-send-email-eduard.munteanu@linux360.ro> <1218388447-5578-5-git-send-email-eduard.munteanu@linux360.ro> <48A046F5.2000505@linux-foundation.org> <1218463774.7813.291.camel@penberg-laptop> <48A048FD.30909@linux-foundation.org> <1218464177.7813.293.camel@penberg-laptop> <48A04AEE.8090606@linux-foundation.org> <1218464557.7813.295.camel@penberg-laptop>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1218464557.7813.295.camel@penberg-laptop>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Pekka Enberg <penberg@cs.helsinki.fi>
Cc: Christoph Lameter <cl@linux-foundation.org>, mathieu.desnoyers@polymtl.ca, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rdunlap@xenotime.net, mpm@selenic.com, rostedt@goodmis.org, tglx@linutronix.de
List-ID: <linux-mm.kvack.org>

On Mon, Aug 11, 2008 at 05:22:37PM +0300, Pekka Enberg wrote:
> On Mon, 2008-08-11 at 09:21 -0500, Christoph Lameter wrote:
> > Pekka Enberg wrote:
> > 
> > > The function call is supposed to go away when we convert kmemtrace to
> > > use Mathieu's markers but I suppose even then we have a problem with
> > > inlining?
> > 
> > The function calls are overwritten with NOPs? Or how does that work?
> 
> I have no idea. Mathieu, Eduard?

Yes, the code is patched at runtime. But AFAIK markers already provide
this stuff (called "immediate values"). Mathieu's tracepoints also do
it. But it's not available on all arches. x86 and x86-64 work as far as
I remember.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
