Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f54.google.com (mail-pb0-f54.google.com [209.85.160.54])
	by kanga.kvack.org (Postfix) with ESMTP id 901376B0039
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 12:31:55 -0500 (EST)
Received: by mail-pb0-f54.google.com with SMTP id uo5so5009204pbc.41
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 09:31:55 -0800 (PST)
Received: from mga09.intel.com (mga09.intel.com. [134.134.136.24])
        by mx.google.com with ESMTP id eb3si6311595pbd.137.2014.01.21.09.31.53
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 09:31:54 -0800 (PST)
Subject: Re: [PATCH v8 3/6] MCS Lock: optimizations and extra comments
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <20140121102626.GV31570@twins.programming.kicks-ass.net>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	 <1390267468.3138.37.camel@schen9-DESK>
	 <20140121102626.GV31570@twins.programming.kicks-ass.net>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 09:31:51 -0800
Message-ID: <1390325511.3138.42.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Peter Zijlstra <peterz@infradead.org>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, 2014-01-21 at 11:26 +0100, Peter Zijlstra wrote:
> On Mon, Jan 20, 2014 at 05:24:28PM -0800, Tim Chen wrote:
> > From: Jason Low <jason.low2@hp.com>
> > 
> > Remove unnecessary operation to assign locked status to 1 if lock is
> > acquired without contention as this value will not be checked by lock
> > holder again and other potential lock contenders will not be looking at
> > their own lock status.
should be "lock contenders will not be looking at lock holder's 
lock status"

Thanks for catching it.

Tim
> 
> Ha, read that again :-)
> 
> 


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
