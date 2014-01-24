Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3767A6B0031
	for <linux-mm@kvack.org>; Fri, 24 Jan 2014 12:03:57 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so3461737pbc.41
        for <linux-mm@kvack.org>; Fri, 24 Jan 2014 09:03:56 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id i3si1808090pbe.199.2014.01.24.09.03.54
        for <linux-mm@kvack.org>;
        Fri, 24 Jan 2014 09:03:55 -0800 (PST)
Subject: Re: [PATCH v9 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140122183539.GM30183@twins.programming.kicks-ass.net>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
	 <1390347382.3138.67.camel@schen9-DESK>
	 <20140122183539.GM30183@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Fri, 24 Jan 2014 09:03:49 -0800
Message-ID: <1390583029.3138.78.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, 2014-01-22 at 19:35 +0100, Peter Zijlstra wrote:
> On Tue, Jan 21, 2014 at 03:36:22PM -0800, Tim Chen wrote:
> > diff --git a/arch/powerpc/include/asm/Kbuild b/arch/powerpc/include/asm/Kbuild
> > index 8b19a80..24027ce 100644
> > --- a/arch/powerpc/include/asm/Kbuild
> > +++ b/arch/powerpc/include/asm/Kbuild
> > @@ -1,6 +1,8 @@
> >  
> > +generic-y += +=
> >  generic-y += clkdev.h
> > +generic-y += mcs_spinlock.h
> >  generic-y += preempt.h
> >  generic-y += rwsem.h
> >  generic-y += trace_clock.h
> > -generic-y += vtime.h
> > +generic-y += vtime.hgeneric-y
> 
> Something went funny there, fixed it.

Thanks for fixing it.  I assume Peter you have picked up
the patch series and merged them?

Tim


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
