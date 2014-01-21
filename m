Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f52.google.com (mail-wg0-f52.google.com [74.125.82.52])
	by kanga.kvack.org (Postfix) with ESMTP id 065CE6B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 04:48:42 -0500 (EST)
Received: by mail-wg0-f52.google.com with SMTP id b13so7660920wgh.31
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 01:48:42 -0800 (PST)
Received: from merlin.infradead.org (merlin.infradead.org. [2001:4978:20e::2])
        by mx.google.com with ESMTPS id ew1si2848463wjd.18.2014.01.21.01.48.41
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 21 Jan 2014 01:48:41 -0800 (PST)
Date: Tue, 21 Jan 2014 10:47:56 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v7 6/6] MCS Lock: add Kconfig entries to allow
 arch-specific hooks
Message-ID: <20140121094756.GQ31570@twins.programming.kicks-ass.net>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917316.3138.16.camel@schen9-DESK>
 <20140120123030.GE31570@twins.programming.kicks-ass.net>
 <1390260717.3138.33.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390260717.3138.33.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, Jan 20, 2014 at 03:31:57PM -0800, Tim Chen wrote:
> On Mon, 2014-01-20 at 13:30 +0100, Peter Zijlstra wrote:

> > Then again, people seem to whinge if you don't keep these Kbuild files
> > sorted, but manually sorting 29 files is just not something I like to
> > do.

> Can you clarify what exactly needs to be sorted?  The Kbuild files
> spit out by git diff appears to be sorted already.

> > diff --git a/arch/alpha/include/asm/Kbuild b/arch/alpha/include/asm/Kbuild
> > index f01fb505ad52..14cbbbcec01f 100644
> > --- a/arch/alpha/include/asm/Kbuild
> > +++ b/arch/alpha/include/asm/Kbuild
> > @@ -4,3 +4,4 @@ generic-y += clkdev.h
> >  generic-y += exec.h
> >  generic-y += trace_clock.h
> >  generic-y += preempt.h
> > +generic-y += mcs_spinlock.h

Last time I checked the Alphabet m came before p.

I generated this patch using:

for i in arch/*/include/asm/Kbuild
do
	echo "generic-y += mcs_spinlock.h" >> $i
done

Which simply appends the new header. However people want these generic-y
thingies sorted by header name. Hence the gawk script I sent which does
just that.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
