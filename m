Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 3B92E6B00E6
	for <linux-mm@kvack.org>; Mon, 25 Nov 2013 13:34:32 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id un15so6334641pbc.27
        for <linux-mm@kvack.org>; Mon, 25 Nov 2013 10:34:31 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id sw1si409677pab.257.2013.11.25.10.34.30
        for <linux-mm@kvack.org>;
        Mon, 25 Nov 2013 10:34:30 -0800 (PST)
Subject: Re: [PATCH v6 4/5] MCS Lock: Barrier corrections
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20131125182450.GF10022@twins.programming.kicks-ass.net>
References: <20131121125616.GI3694@twins.programming.kicks-ass.net>
	 <20131121132041.GS4138@linux.vnet.ibm.com>
	 <20131121172558.GA27927@linux.vnet.ibm.com>
	 <20131121215249.GZ16796@laptop.programming.kicks-ass.net>
	 <20131121221859.GH4138@linux.vnet.ibm.com>
	 <20131122155835.GR3866@twins.programming.kicks-ass.net>
	 <20131122182632.GW4138@linux.vnet.ibm.com>
	 <20131122185107.GJ4971@laptop.programming.kicks-ass.net>
	 <20131125173540.GK3694@twins.programming.kicks-ass.net>
	 <20131125180250.GR4138@linux.vnet.ibm.com>
	 <20131125182450.GF10022@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 25 Nov 2013 10:34:02 -0800
Message-ID: <1385404442.11046.526.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Mon, 2013-11-25 at 19:24 +0100, Peter Zijlstra wrote:
> On Mon, Nov 25, 2013 at 10:02:50AM -0800, Paul E. McKenney wrote:
> > I still do not believe that it does.  Again, strangely enough.
> > 
> > We need to ask someone in Intel that understands this all the way down
> > to the silicon.  The guy I used to rely on for this no longer works
> > at Intel.
> > 
> > Do you know someone who fits this description, or should I start sending
> > cold-call emails to various Intel contacts?
> 
> There's a whole bunch of Intel folks on the Cc. list; could one of you
> find a suitable HW engineer and put him onto this thread?

I'll try to do some asking around.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
