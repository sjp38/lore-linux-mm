Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f179.google.com (mail-pd0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id B0B386B0143
	for <linux-mm@kvack.org>; Thu,  7 Nov 2013 03:13:13 -0500 (EST)
Received: by mail-pd0-f179.google.com with SMTP id y10so245176pdj.24
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:13:13 -0800 (PST)
Received: from psmtp.com ([74.125.245.103])
        by mx.google.com with SMTP id tu7si2128286pab.191.2013.11.07.00.13.11
        for <linux-mm@kvack.org>;
        Thu, 07 Nov 2013 00:13:12 -0800 (PST)
Received: by mail-ee0-f43.google.com with SMTP id b47so99591eek.16
        for <linux-mm@kvack.org>; Thu, 07 Nov 2013 00:13:09 -0800 (PST)
Date: Thu, 7 Nov 2013 09:13:06 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v3 3/5] MCS Lock: Barrier corrections
Message-ID: <20131107081306.GA32438@gmail.com>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
 <1383773827.11046.355.camel@schen9-DESK>
 <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CA+55aFyNX=5i0hmk-KuD+Vk+yBD-kkAiywx1Lx_JJmHVPx=1wA@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Arnd Bergmann <arnd@arndb.de>, "Figo. zhang" <figo1802@gmail.com>, Aswin Chandramouleeswaran <aswin@hp.com>, Rik van Riel <riel@redhat.com>, Waiman Long <waiman.long@hp.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, linux-arch@vger.kernel.org, Andi Kleen <andi@firstfloor.org>, Peter Zijlstra <a.p.zijlstra@chello.nl>, George Spelvin <linux@horizon.com>, Michel Lespinasse <walken@google.com>, Ingo Molnar <mingo@elte.hu>, Peter Hurley <peter@hurleysoftware.com>, "H. Peter Anvin" <hpa@zytor.com>, Andrew Morton <akpm@linux-foundation.org>, linux-mm <linux-mm@kvack.org>, Alex Shi <alex.shi@linaro.org>, Andrea Arcangeli <aarcange@redhat.com>, Scott J Norton <scott.norton@hp.com>, linux-kernel@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>, Dave Hansen <dave.hansen@intel.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Will Deacon <will.deacon@arm.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>


Linus,

A more general maintenance question: do you agree with the whole idea to 
factor out the MCS logic from mutex.c to make it reusable?

This optimization patch makes me think it's a useful thing to do:

  [PATCH v3 2/5] MCS Lock: optimizations and extra comments

as that kicks back optimizations to the mutex code as well. It also 
brought some spotlight on mutex code that it would not have gotten 
otherwise.

That advantage is also its disadvantage: additional coupling between rwsem 
and mutex logic internals. But not like it's overly hard to undo this 
change, so I'm in general in favor of this direction ...

So unless you object to this direction, I planned to apply this 
preparatory series to the locking tree once we are all happy with all the 
fine details.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
