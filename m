Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f45.google.com (mail-wg0-f45.google.com [74.125.82.45])
	by kanga.kvack.org (Postfix) with ESMTP id EBBE26B006E
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 08:06:24 -0500 (EST)
Received: by mail-wg0-f45.google.com with SMTP id n12so291496wgh.0
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:06:24 -0800 (PST)
Received: from mail-ee0-x229.google.com (mail-ee0-x229.google.com [2a00:1450:4013:c00::229])
        by mx.google.com with ESMTPS id ce1si6758768wib.20.2014.01.22.05.06.23
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 22 Jan 2014 05:06:23 -0800 (PST)
Received: by mail-ee0-f41.google.com with SMTP id e49so4892059eek.14
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:06:23 -0800 (PST)
Date: Wed, 22 Jan 2014 14:06:19 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v8 4/6] MCS Lock: Move mcs_lock/unlock function into its
 own
Message-ID: <20140122130619.GA9429@gmail.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
 <1390267471.3138.38.camel@schen9-DESK>
 <20140121101915.GS31570@twins.programming.kicks-ass.net>
 <20140121104140.GA4092@gmail.com>
 <1390330623.3138.56.camel@schen9-DESK>
 <20140121190658.GA5862@gmail.com>
 <1390331671.3138.58.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390331671.3138.58.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Tim Chen <tim.c.chen@linux.intel.com> wrote:

> > > For the time being, I'll just remove the EXPORT.  If people feel 
> > > that inline is the right way to go, then we'll leave the 
> > > function in mcs_spin_lock.h and not create mcs_spin_lock.c.
> > 
> > Well, 'people' could be you, the person touching the code? This is 
> > really something that is discoverable: look at the critical path 
> > in the inlined and the out of line case, and compare the number of 
> > instructions. This can be done based on disassembly of the 
> > affected code.
> 
> Okay, will make it inline function and drop the move of to 
> mcs_spin_lock.c

Only if I'm right! I was speculating.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
