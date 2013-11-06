Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f46.google.com (mail-pa0-f46.google.com [209.85.220.46])
	by kanga.kvack.org (Postfix) with ESMTP id 676426B011B
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:43:41 -0500 (EST)
Received: by mail-pa0-f46.google.com with SMTP id rd3so276198pab.33
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:43:41 -0800 (PST)
Received: from psmtp.com ([74.125.245.142])
        by mx.google.com with SMTP id jp3si114736pbc.336.2013.11.06.13.43.38
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:43:39 -0800 (PST)
Message-ID: <527AB7CA.4020502@zytor.com>
Date: Wed, 06 Nov 2013 13:42:34 -0800
From: "H. Peter Anvin" <hpa@zytor.com>
MIME-Version: 1.0
Subject: Re: [PATCH v3 0/4] MCS Lock: MCS lock code cleanup and optimizations
References: <cover.1383771175.git.tim.c.chen@linux.intel.com> <1383773816.11046.352.camel@schen9-DESK>
In-Reply-To: <1383773816.11046.352.camel@schen9-DESK>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On 11/06/2013 01:36 PM, Tim Chen wrote:
> In this patch series, we separated out the MCS lock code which was
> previously embedded in the mutex.c.  This allows for easier reuse of
> MCS lock in other places like rwsem and qrwlock.  We also did some micro
> optimizations and barrier cleanup.
> 
> This patches were previously part of the rwsem optimization patch series
> but now we spearate them out.
> 
> Tim Chen

Perhaps I'm missing something here, but what is MCS lock and what is the
value?

	-hpa


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
