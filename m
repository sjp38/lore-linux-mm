Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f47.google.com (mail-qa0-f47.google.com [209.85.216.47])
	by kanga.kvack.org (Postfix) with ESMTP id 24BC06B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:59:56 -0500 (EST)
Received: by mail-qa0-f47.google.com with SMTP id j5so6313151qaq.6
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:59:55 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id j77si2799830qge.144.2014.01.21.02.59.54
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jan 2014 02:59:55 -0800 (PST)
Date: Tue, 21 Jan 2014 11:59:16 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
Message-ID: <20140121105916.GW31570@twins.programming.kicks-ass.net>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
 <1390267479.3138.40.camel@schen9-DESK>
 <20140121102000.GT31570@twins.programming.kicks-ass.net>
 <20140121104521.GA4105@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121104521.GA4105@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@kernel.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Jan 21, 2014 at 11:45:21AM +0100, Ingo Molnar wrote:
> 
> * Peter Zijlstra <peterz@infradead.org> wrote:
> 
> > On Mon, Jan 20, 2014 at 05:24:39PM -0800, Tim Chen wrote:
> > > diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
> > > index f01fb50..14cbbbc 100644
> > > --- a/arch/alpha/include/asm/Kbuild
> > > +++ b/arch/alpha/include/asm/Kbuild
> > > @@ -4,3 +4,4 @@ generic-y += clkdev.h
> > >  generic-y += exec.h
> > >  generic-y += trace_clock.h
> > >  generic-y += preempt.h
> > > +generic-y += mcs_spinlock.h
> > 
> > m < p
> 
> Hm, did your script not work?

It wasn't used, afaict.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
