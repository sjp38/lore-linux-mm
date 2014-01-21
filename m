Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id 05B046B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 09:00:28 -0500 (EST)
Received: by mail-wi0-f170.google.com with SMTP id ex4so5562744wid.3
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:00:28 -0800 (PST)
Received: from mail-ea0-x234.google.com (mail-ea0-x234.google.com [2a00:1450:4013:c01::234])
        by mx.google.com with ESMTPS id gk11si3506014wic.71.2014.01.21.06.00.27
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 21 Jan 2014 06:00:28 -0800 (PST)
Received: by mail-ea0-f180.google.com with SMTP id f15so3786447eak.11
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 06:00:27 -0800 (PST)
Date: Tue, 21 Jan 2014 15:00:23 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
Message-ID: <20140121140023.GA4537@gmail.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
 <1390267479.3138.40.camel@schen9-DESK>
 <20140121102000.GT31570@twins.programming.kicks-ass.net>
 <20140121104521.GA4105@gmail.com>
 <20140121105916.GW31570@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140121105916.GW31570@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Peter Zijlstra <peterz@infradead.org> wrote:

> On Tue, Jan 21, 2014 at 11:45:21AM +0100, Ingo Molnar wrote:
> > 
> > * Peter Zijlstra <peterz@infradead.org> wrote:
> > 
> > > On Mon, Jan 20, 2014 at 05:24:39PM -0800, Tim Chen wrote:
> > > > diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
> > > > index f01fb50..14cbbbc 100644
> > > > --- a/arch/alpha/include/asm/Kbuild
> > > > +++ b/arch/alpha/include/asm/Kbuild
> > > > @@ -4,3 +4,4 @@ generic-y += clkdev.h
> > > >  generic-y += exec.h
> > > >  generic-y += trace_clock.h
> > > >  generic-y += preempt.h
> > > > +generic-y += mcs_spinlock.h
> > > 
> > > m < p
> > 
> > Hm, did your script not work?
> 
> It wasn't used, afaict.

Something to keep in mind for the next version of this series I 
suspect ;-)

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
