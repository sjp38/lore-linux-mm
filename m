Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f181.google.com (mail-pd0-f181.google.com [209.85.192.181])
	by kanga.kvack.org (Postfix) with ESMTP id ED4076B0078
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 16:39:46 -0500 (EST)
Received: by mail-pd0-f181.google.com with SMTP id y10so5169743pdj.12
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 13:39:46 -0800 (PST)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id xy6si6951551pab.298.2014.01.21.13.39.43
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 13:39:45 -0800 (PST)
Subject: Re: [PATCH v8 3/6] MCS Lock: optimizations and extra comments
From: Tim Chen <tim.c.chen@linux.intel.com>
In-Reply-To: <CAGQ1y=6SDNen_w4AVdbmvwat5RjuDb7OCtb_aUQzfqwJU3fMDw@mail.gmail.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
	 <1390267468.3138.37.camel@schen9-DESK>
	 <CAGQ1y=6SDNen_w4AVdbmvwat5RjuDb7OCtb_aUQzfqwJU3fMDw@mail.gmail.com>
Content-Type: text/plain; charset="UTF-8"
Date: Tue, 21 Jan 2014 13:39:02 -0800
Message-ID: <1390340342.3138.59.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Jason Low <jason.low2@hp.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Will Deacon <will.deacon@arm.com>, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, 2014-01-21 at 13:01 -0800, Jason Low wrote:
> /*
>  * Lock acquired, don't need to set node->locked to 1. Threads
>  * only spin on its own node->locked value for lock acquisition.
>  * However, since this thread can immediately acquire the lock
>  * and does not proceed to spin on its own node->locked, this
>  * value won't be used. If a debug mode is needed to
>  * audit lock status, then set node->locked value here.
>  */ 

I'll update the comment accordingly.

Tim

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
