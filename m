Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f45.google.com (mail-pb0-f45.google.com [209.85.160.45])
	by kanga.kvack.org (Postfix) with ESMTP id 3947B6B00A6
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 17:26:23 -0500 (EST)
Received: by mail-pb0-f45.google.com with SMTP id un15so5307168pbc.18
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 14:26:22 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id i8si7085899pav.219.2014.01.21.14.26.21
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 14:26:21 -0800 (PST)
Subject: Re: [PATCH v8 6/6] MCS Lock: Allow architecture specific asm files
 to be used for contended case
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140121102000.GT31570@twins.programming.kicks-ass.net>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	 <1390267479.3138.40.camel@schen9-DESK>
	 <20140121102000.GT31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 14:25:25 -0800
Message-ID: <1390343125.3138.60.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, 2014-01-21 at 11:20 +0100, Peter Zijlstra wrote:
> On Mon, Jan 20, 2014 at 05:24:39PM -0800, Tim Chen wrote:
> > diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
> > index f01fb50..14cbbbc 100644
> > --- a/arch/alpha/include/asm/Kbuild
> > +++ b/arch/alpha/include/asm/Kbuild
> > @@ -4,3 +4,4 @@ generic-y += clkdev.h
> >  generic-y += exec.h
> >  generic-y += trace_clock.h
> >  generic-y += preempt.h
> > +generic-y += mcs_spinlock.h
> 
> m < p
> 
> > --- a/arch/ia64/include/asm/Kbuild
> > +++ b/arch/ia64/include/asm/Kbuild
> > @@ -4,4 +4,4 @@ generic-y += exec.h
> >  generic-y += kvm_para.h
> >  generic-y += trace_clock.h
> >  generic-y += preempt.h
> > -generic-y += vtime.h
> > \ No newline at end of file

The no newline compliant apparently caused by
existing Kbuild file.

Tim

> > +generic-y += vtime.hgeneric-y += mcs_spinlock.h
> 
> EOL fail
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
