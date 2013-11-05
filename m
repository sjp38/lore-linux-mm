Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id DC1A86B003D
	for <linux-mm@kvack.org>; Tue,  5 Nov 2013 06:15:18 -0500 (EST)
Received: by mail-pd0-f173.google.com with SMTP id r10so8215789pdi.32
        for <linux-mm@kvack.org>; Tue, 05 Nov 2013 03:15:18 -0800 (PST)
Received: from psmtp.com ([74.125.245.106])
        by mx.google.com with SMTP id i8si4226441paa.126.2013.11.05.03.15.16
        for <linux-mm@kvack.org>;
        Tue, 05 Nov 2013 03:15:17 -0800 (PST)
Date: Tue, 5 Nov 2013 12:14:35 +0100
From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: [PATCH 4/4] MCS Lock: Make mcs_spinlock.h includable in other
 files
Message-ID: <20131105111435.GN28601@twins.programming.kicks-ass.net>
References: <cover.1383604526.git.tim.c.chen@linux.intel.com>
 <1383608233.11046.263.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1383608233.11046.263.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

On Mon, Nov 04, 2013 at 03:37:13PM -0800, Tim Chen wrote:
> +EXPORT_SYMBOL(mcs_spin_lock);

If that can be a GPL, please make it so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
