Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f42.google.com (mail-wg0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 9D5686B0035
	for <linux-mm@kvack.org>; Tue, 21 Jan 2014 05:13:53 -0500 (EST)
Received: by mail-wg0-f42.google.com with SMTP id l18so4801526wgh.3
        for <linux-mm@kvack.org>; Tue, 21 Jan 2014 02:13:53 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id n2si3036752wiz.53.2014.01.21.02.13.52
        for <linux-mm@kvack.org>;
        Tue, 21 Jan 2014 02:13:52 -0800 (PST)
Date: Tue, 21 Jan 2014 10:12:11 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v8 5/6] MCS Lock: allow architectures to hook in to
 contended
Message-ID: <20140121101211.GC30706@mudshark.cambridge.arm.com>
References: <cover.1390239879.git.tim.c.chen@linux.intel.com>
 <1390267475.3138.39.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390267475.3138.39.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

Hi Tim,

On Tue, Jan 21, 2014 at 01:24:35AM +0000, Tim Chen wrote:
> From: Will Deacon <will.deacon@arm.com>
> 
> When contended, architectures may be able to reduce the polling overhead
> in ways which aren't expressible using a simple relax() primitive.
> 
> This patch allows architectures to hook into the mcs_{lock,unlock}
> functions for the contended cases only.
> 
> Signed-off-by: Will Deacon <will.deacon@arm.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>

Not a huge problem, but the subject for this patch seem to have been
truncated (should be "... contended paths").

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
