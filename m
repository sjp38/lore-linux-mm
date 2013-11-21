Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f172.google.com (mail-ob0-f172.google.com [209.85.214.172])
	by kanga.kvack.org (Postfix) with ESMTP id 149DF6B0036
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 08:18:15 -0500 (EST)
Received: by mail-ob0-f172.google.com with SMTP id gq1so6721645obb.17
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 05:18:14 -0800 (PST)
Received: from e31.co.us.ibm.com (e31.co.us.ibm.com. [32.97.110.149])
        by mx.google.com with ESMTPS id n6si19383728oeq.134.2013.11.21.05.18.13
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 21 Nov 2013 05:18:14 -0800 (PST)
Received: from /spool/local
	by e31.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Thu, 21 Nov 2013 06:18:13 -0700
Received: from b03cxnp08027.gho.boulder.ibm.com (b03cxnp08027.gho.boulder.ibm.com [9.17.130.19])
	by d03dlp02.boulder.ibm.com (Postfix) with ESMTP id 88F1D3E40040
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 06:18:10 -0700 (MST)
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by b03cxnp08027.gho.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id rALBGNnH27983922
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 12:16:23 +0100
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id rALDL3xd024706
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 06:21:04 -0700
Date: Thu, 21 Nov 2013 05:18:06 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121131806.GQ4138@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <1384973026.11046.465.camel@schen9-DESK>
 <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
 <20131121104503.GB10022@twins.programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131121104503.GB10022@twins.programming.kicks-ass.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 11:45:03AM +0100, Peter Zijlstra wrote:
> On Wed, Nov 20, 2013 at 08:53:33PM -0800, Paul E. McKenney wrote:
> > The other option is to weaken lock semantics so that unlock-lock no
> > longer implies a full barrier, but I believe that we would regret taking
> > that path.  (It would be OK by me, I would just add a few smp_mb()
> > calls on various slowpaths in RCU.  But...)
> 
> Please no, I know we rely on it in a number of places, I just can't
> remember where all those were :/

;-) ;-) ;-)

Yeah, I would also have to overprovision smp_mb()s in a number of
places.  Then again, I know that I don't rely on this on any of
RCU's fastpaths.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
