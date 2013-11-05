Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f52.google.com (mail-pb0-f52.google.com [209.85.160.52])
	by kanga.kvack.org (Postfix) with ESMTP id 66A1D6B0092
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 16:14:20 -0500 (EST)
Received: by mail-pb0-f52.google.com with SMTP id rr4so1536763pbb.39
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 13:14:19 -0800 (PST)
Received: from psmtp.com ([74.125.245.124])
        by mx.google.com with SMTP id it5si14745176pbc.5.2013.11.05.13.14.17
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 13:14:18 -0800 (PST)
Received: by mail-qe0-f45.google.com with SMTP id 8so5428250qea.18
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 13:14:16 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <1383673346.11046.276.camel@schen9-DESK>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
	<1383673346.11046.276.camel@schen9-DESK>
Date: Tue, 5 Nov 2013 13:14:16 -0800
Message-ID: <CANN689He+1uW2UpfLtjrtBO8_F=5EX4MnynXbp8rV7uTeD+5aw@mail.gmail.com>
Subject: Re: [PATCH v2 0/4] MCS Lock: MCS lock code cleanup and optimizations
From: Michel Lespinasse <walken@google.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>

On Tue, Nov 5, 2013 at 9:42 AM, Tim Chen <tim.c.chen@linux.intel.com> wrote:
> In this patch series, we separated out the MCS lock code which was
> previously embedded in the mutex.c.  This allows for easier reuse of
> MCS lock in other places like rwsem and qrwlock.  We also did some micro
> optimizations and barrier cleanup.
>
> This patches were previously part of the rwsem optimization patch series
> but now we spearate them out.
>
> Tim Chen
>
> v2:
> 1. change export mcs_spin_lock as a GPL export symbol
> 2. corrected mcs_spin_lock to references
>
> Jason Low (2):
>   MCS Lock: optimizations and extra comments
>   MCS Lock: Barrier corrections
>
> Tim Chen (1):
>   MCS Lock: Restructure the MCS lock defines and locking code into its
>     own file
>
> Waiman Long (1):
>   MCS Lock: Make mcs_spinlock.h includable in other files
>
>  include/linux/mcs_spinlock.h |   99 ++++++++++++++++++++++++++++++++++++++++++
>  include/linux/mutex.h        |    5 +-
>  kernel/Makefile              |    6 +-
>  kernel/mcs_spinlock.c        |   21 +++++++++
>  kernel/mutex.c               |   60 +++----------------------
>  5 files changed, 133 insertions(+), 58 deletions(-)
>  create mode 100644 include/linux/mcs_spinlock.h
>  create mode 100644 kernel/mcs_spinlock.c

What base kernel does this apply over ?

-- 
Michel "Walken" Lespinasse
A program is never fully debugged until the last user dies.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
