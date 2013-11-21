Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f51.google.com (mail-pb0-f51.google.com [209.85.160.51])
	by kanga.kvack.org (Postfix) with ESMTP id 62DD26B0039
	for <linux-mm@kvack.org>; Thu, 21 Nov 2013 05:19:30 -0500 (EST)
Received: by mail-pb0-f51.google.com with SMTP id up15so6669878pbc.10
        for <linux-mm@kvack.org>; Thu, 21 Nov 2013 02:19:30 -0800 (PST)
Received: from psmtp.com ([74.125.245.171])
        by mx.google.com with SMTP id vs7si16561849pbc.325.2013.11.21.02.19.26
        for <linux-mm@kvack.org>;
        Thu, 21 Nov 2013 02:19:28 -0800 (PST)
Date: Thu, 21 Nov 2013 10:17:36 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
Message-ID: <20131121101736.GA13067@mudshark.cambridge.arm.com>
References: <1384911463.11046.454.camel@schen9-DESK>
 <20131120153123.GF4138@linux.vnet.ibm.com>
 <20131120154643.GG19352@mudshark.cambridge.arm.com>
 <20131120171400.GI4138@linux.vnet.ibm.com>
 <1384973026.11046.465.camel@schen9-DESK>
 <20131120190616.GL4138@linux.vnet.ibm.com>
 <1384979767.11046.489.camel@schen9-DESK>
 <20131120214402.GM4138@linux.vnet.ibm.com>
 <1384991514.11046.504.camel@schen9-DESK>
 <20131121045333.GO4138@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20131121045333.GO4138@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Thu, Nov 21, 2013 at 04:53:33AM +0000, Paul E. McKenney wrote:
> On Wed, Nov 20, 2013 at 03:51:54PM -0800, Tim Chen wrote:
> > If we intend to use smp_load_acquire and smp_store_release extensively
> > for locks, making RCsc semantics the default will simply things a lot.
> 
> The other option is to weaken lock semantics so that unlock-lock no
> longer implies a full barrier, but I believe that we would regret taking
> that path.  (It would be OK by me, I would just add a few smp_mb()
> calls on various slowpaths in RCU.  But...)

Unsurprisingly, my vote is for RCsc semantics.

One major advantage (in my opinion) of the acquire/release accessors is that
they feel intuitive in an area where intuition is hardly rife. I believe
that the additional reordering permitted by RCpc detracts from the relative
simplicity of what is currently being proposed.

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
