Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 9D9756B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 14:31:35 -0500 (EST)
Received: by mail-pd0-f182.google.com with SMTP id v10so7210100pde.13
        for <linux-mm@kvack.org>; Mon, 20 Jan 2014 11:31:35 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id s4si2379138pbg.213.2014.01.20.11.31.33
        for <linux-mm@kvack.org>;
        Mon, 20 Jan 2014 11:31:34 -0800 (PST)
Subject: Re: [PATCH v7 1/6] MCS Lock: Restructure the MCS lock defines and
 locking code into its own file
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140120120756.GB31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
	 <1389917296.3138.11.camel@schen9-DESK>
	 <20140120120756.GB31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 20 Jan 2014 11:31:31 -0800
Message-ID: <1390246291.3138.31.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, 2014-01-20 at 13:07 +0100, Peter Zijlstra wrote:
> On Thu, Jan 16, 2014 at 04:08:16PM -0800, Tim Chen wrote:
> > +/*
> > + * We don't inline mcs_spin_lock() so that perf can correctly account for the
> > + * time spent in this lock function.
> > + */
> > +static noinline
> > +void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> 
> But given a vmlinux with sufficient DWARFs in, the IP will resolve to a
> .ista. symbol, no?

I'm actually only renaming the mspin_lock code to mcs_spin_lock here
and moving the code to header file.
The noinline logic was in the original code.  Later on when we move 
mcs_spin_lock to its own file and exporting the symbol, then I 
think this issue will be resolved.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
