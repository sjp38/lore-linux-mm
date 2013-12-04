Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qe0-f46.google.com (mail-qe0-f46.google.com [209.85.128.46])
	by kanga.kvack.org (Postfix) with ESMTP id 3D9FA6B0062
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 17:07:51 -0500 (EST)
Received: by mail-qe0-f46.google.com with SMTP id a11so16246428qen.5
        for <linux-mm@kvack.org>; Wed, 04 Dec 2013 14:07:51 -0800 (PST)
Received: from e34.co.us.ibm.com (e34.co.us.ibm.com. [32.97.110.152])
        by mx.google.com with ESMTPS id r7si28798672qcz.61.2013.12.04.14.07.49
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 04 Dec 2013 14:07:50 -0800 (PST)
Received: from /spool/local
	by e34.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Wed, 4 Dec 2013 15:07:49 -0700
Received: from b03cxnp08025.gho.boulder.ibm.com (b03cxnp08025.gho.boulder.ibm.com [9.17.130.17])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 2547BC40003
	for <linux-mm@kvack.org>; Wed,  4 Dec 2013 15:07:26 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08025.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rB4K5tIn6619612
	for <linux-mm@kvack.org>; Wed, 4 Dec 2013 21:05:55 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rB4MAj0Q013293
	for <linux-mm@kvack.org>; Wed, 4 Dec 2013 15:10:47 -0700
Date: Wed, 4 Dec 2013 14:07:44 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131204220744.GG15492@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <cover.1384885312.git.tim.c.chen@linux.intel.com>
 <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <20131121110308.GC10022@twins.programming.kicks-ass.net>
 <20131121125616.GI3694@twins.programming.kicks-ass.net>
 <20131121132041.GS4138@linux.vnet.ibm.com>
 <20131121172558.GA27927@linux.vnet.ibm.com>
 <20131204212613.GA21717@two.firstfloor.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131204212613.GA21717@two.firstfloor.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andi Kleen <andi@firstfloor.org>
Cc: Peter Zijlstra <peterz@infradead.org>, Will Deacon <will.deacon@arm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, Dec 04, 2013 at 10:26:13PM +0100, Andi Kleen wrote:
> > Let's apply the Intel manual to the earlier example:
> > 
> > 	CPU 0		CPU 1			CPU 2
> > 	-----		-----			-----
> > 	x = 1;		r1 = SLA(lock);		y = 1;
> > 	SSR(lock, 1);	r2 = y;			smp_mb();
> > 						r3 = x;
> > 
> > 	assert(!(r1 == 1 && r2 == 0 && r3 == 0));
> 
> Hi Paul,
> 
> We discussed this example with CPU architects and they
> agreed that it is valid to rely on (r1 == 1 && r2 == 0 && r3 == 0)
> never happening.
> 
> So the MCS code is good without additional barriers.

Good to hear!!!  Thank you, Andi!

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
