Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f177.google.com (mail-pd0-f177.google.com [209.85.192.177])
	by kanga.kvack.org (Postfix) with ESMTP id 711336B0082
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 13:57:47 -0500 (EST)
Received: by mail-pd0-f177.google.com with SMTP id p10so8882747pdj.8
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 10:57:47 -0800 (PST)
Received: from psmtp.com ([74.125.245.167])
        by mx.google.com with SMTP id gw3si14723022pac.114.2013.11.05.10.57.45
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 10:57:45 -0800 (PST)
Date: Tue, 5 Nov 2013 19:57:17 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH v2 4/4] MCS Lock: Make mcs_spinlock.h includable in other
 files
Message-ID: <20131105185717.GZ16117@laptop.programming.kicks-ass.net>
References: <cover.1383670202.git.tim.c.chen@linux.intel.com>
 <1383673359.11046.280.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383673359.11046.280.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>

On Tue, Nov 05, 2013 at 09:42:39AM -0800, Tim Chen wrote:
> + * The _raw_mcs_spin_lock() function should not be called directly. Instead,
> + * users should call mcs_spin_lock().
>   */
> -static noinline
> -void mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
> +static inline
> +void _raw_mcs_spin_lock(struct mcs_spinlock **lock, struct mcs_spinlock *node)
>  {
>  	struct mcs_spinlock *prev;
>  

So why keep it in the header at all?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
