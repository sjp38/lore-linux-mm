Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f176.google.com (mail-we0-f176.google.com [74.125.82.176])
	by kanga.kvack.org (Postfix) with ESMTP id CBB776B0031
	for <linux-mm@kvack.org>; Fri, 29 Nov 2013 13:20:08 -0500 (EST)
Received: by mail-we0-f176.google.com with SMTP id w62so3976555wes.35
        for <linux-mm@kvack.org>; Fri, 29 Nov 2013 10:20:08 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id fb7si20774729wjc.173.2013.11.29.10.20.07
        for <linux-mm@kvack.org>;
        Fri, 29 Nov 2013 10:20:08 -0800 (PST)
Date: Fri, 29 Nov 2013 18:18:17 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131129181817.GL31000@mudshark.cambridge.arm.com>
References: <20131127101613.GC9032@mudshark.cambridge.arm.com>
 <20131127171143.GN4137@linux.vnet.ibm.com>
 <20131128114058.GC21354@mudshark.cambridge.arm.com>
 <20131128173853.GV4137@linux.vnet.ibm.com>
 <20131128180318.GE16203@mudshark.cambridge.arm.com>
 <20131128182712.GW4137@linux.vnet.ibm.com>
 <20131128185341.GG16203@mudshark.cambridge.arm.com>
 <20131128195039.GX4137@linux.vnet.ibm.com>
 <20131129161711.GG31000@mudshark.cambridge.arm.com>
 <CA+55aFwHgnH4h0YwybThQjvicFCVbGbwaAy3Fw0b738gJMtqBA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFwHgnH4h0YwybThQjvicFCVbGbwaAy3Fw0b738gJMtqBA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Arnd Bergmann <arnd@arndb.de>, "Figo. zhang" <figo1802@gmail.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Rik van Riel <riel@redhat.com>, Waiman Long <waiman.long@hp.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Andi Kleen <andi@firstfloor.org>, George Spelvin <linux@horizon.com>, Tim Chen <tim.c.chen@linux.intel.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Alex Shi <alex.shi@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Scott J Norton <scott.norton@hp.com>, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <peterz@infradead.org>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>

On Fri, Nov 29, 2013 at 04:44:41PM +0000, Linus Torvalds wrote:
> 
> On Nov 29, 2013 8:18 AM, "Will Deacon"
> <will.deacon@arm.com<mailto:will.deacon@arm.com>> wrote:
> >
> >  To get some sort of idea, I tried adding a dmb to the start of
> >  spin_unlock on ARMv7 and I saw a 3% performance hit in hackbench on my
> >  dual-cluster board.
> 
> Don't do a dmb. Just do a dummy release. You just said that on arm64 a
> unlock+lock is a memory barrier, so just make the mb__before_spinlock() be
> a dummy store with release to the stack..

Good idea! That should work quite nicely (I don't have anything sane I can
benchmark it on), so I think that solves the issue I was moaning about.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
