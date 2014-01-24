Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-bk0-f43.google.com (mail-bk0-f43.google.com [209.85.214.43])
	by kanga.kvack.org (Postfix) with ESMTP id 62A306B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 12:08:13 -0500 (EST)
Received: by mail-bk0-f43.google.com with SMTP id mx11so1311433bkb.30
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:08:12 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ql3si3735338bkb.198.2014.01.24.09.08.12
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 24 Jan 2014 09:08:12 -0800 (PST)
Date: Fri, 24 Jan 2014 18:07:27 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v9 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
Message-ID: <20140124170727.GG31570@twins.programming.kicks-ass.net>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
 <1390347382.3138.67.camel@schen9-DESK>
 <20140122183539.GM30183@twins.programming.kicks-ass.net>
 <1390583029.3138.78.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390583029.3138.78.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Fri, Jan 24, 2014 at 09:03:49AM -0800, Tim Chen wrote:
> On Wed, 2014-01-22 at 19:35 +0100, Peter Zijlstra wrote:
> > On Tue, Jan 21, 2014 at 03:36:22PM -0800, Tim Chen wrote:
> > > diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
> > > index 8b19a80..24027ce 100644
> > > --- a/arch/powerpc/include/asm/Kbuild
> > > +++ b/arch/powerpc/include/asm/Kbuild
> > > @@ -1,6 +1,8 @@
> > >  
> > > +generic-y += +=
> > >  generic-y += clkdev.h
> > > +generic-y += mcs_spinlock.h
> > >  generic-y += preempt.h
> > >  generic-y += rwsem.h
> > >  generic-y += trace_clock.h
> > > -generic-y += vtime.h
> > > +generic-y += vtime.hgeneric-y
> > 
> > Something went funny there, fixed it.
> 
> Thanks for fixing it.  I assume Peter you have picked up
> the patch series and merged them?

I have picked up, Ingo generally doesn't merge new patches until after
-rc1 closes though, with the obvious exception to 'urgent' patches that
fix problems stemming from the merge window.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
