Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f180.google.com (mail-ea0-f180.google.com [209.85.215.180])
	by kanga.kvack.org (Postfix) with ESMTP id 4E1F16B004D
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 16:26:15 -0500 (EST)
Received: by mail-ea0-f180.google.com with SMTP id f15so11040817eak.11
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 13:26:14 -0800 (PST)
Received: from one.firstfloor.org (one.firstfloor.org. [193.170.194.197])
        by mx.google.com with ESMTPS id i1si8346178eev.89.2013.12.04.13.26.14
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 13:26:14 -0800 (PST)
Date: Wed, 4 Dec 2013 22:26:13 +0100
From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131204212613.GA21717@two.firstfloor.org>
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131121172558.GA27927@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

> Let's apply the Intel manual to the earlier example:
> 
> 	CPU 0		CPU 1			CPU 2
> 	-----		-----			-----
> 	x = 1;		r1 = SLA(lock);		y = 1;
> 	SSR(lock, 1);	r2 = y;			smp_mb();
> 						r3 = x;
> 
> 	assert(!(r1 == 1 && r2 == 0 && r3 == 0));

Hi Paul,

We discussed this example with CPU architects and they
agreed that it is valid to rely on (r1 == 1 && r2 == 0 && r3 == 0)
never happening.

So the MCS code is good without additional barriers.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
