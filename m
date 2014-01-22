Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 8BCB66B0035
	for <linux-mm@kvack.org>; Wed, 22 Jan 2014 05:14:53 -0500 (EST)
Received: by mail-wi0-f169.google.com with SMTP id e4so6512419wiv.0
        for <linux-mm@kvack.org>; Wed, 22 Jan 2014 02:14:53 -0800 (PST)
Received: from cam-admin0.cambridge.arm.com (cam-admin0.cambridge.arm.com. [217.140.96.50])
        by mx.google.com with ESMTP id mg5si6257454wic.40.2014.01.22.02.14.52
        for <linux-mm@kvack.org>;
        Wed, 22 Jan 2014 02:14:52 -0800 (PST)
Date: Wed, 22 Jan 2014 10:13:01 +0000
From: Will Deacon <will.deacon@arm.com>
Subject: Re: [PATCH v9 1/6] MCS Lock: Barrier corrections
Message-ID: <20140122101301.GA1621@mudshark.cambridge.arm.com>
References: <cover.1390320729.git.tim.c.chen@linux.intel.com>
 <1390347353.3138.62.camel@schen9-DESK>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <1390347353.3138.62.camel@schen9-DESK>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm <linux-mm@kvack.org>, "linux-arch@vger.kernel.org" <linux-arch@vger.kernel.org>, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>

On Tue, Jan 21, 2014 at 11:35:53PM +0000, Tim Chen wrote:
> From: Waiman Long <Waiman.Long@hp.com>
> 
> This patch corrects the way memory barriers are used in the MCS lock
> with smp_load_acquire and smp_store_release fucnctions.  The previous
> barriers could leak critical sections if mcs lock is used by itself.
> It is not a problem when mcs lock is embedded in mutex but will be an
> issue when the mcs_lock is used elsewhere.
> 
> The patch removes the incorrect barriers and put in correct
> barriers with the pair of functions smp_load_acquire and smp_store_release.
> 
> Suggested-by: Michel Lespinasse <walken@google.com>
> Reviewed-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Signed-off-by: Waiman Long <Waiman.Long@hp.com>
> Signed-off-by: Jason Low <jason.low2@hp.com>
> Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> ---
>  kernel/locking/mutex.c | 18 +++++++++++++-----
>  1 file changed, 13 insertions(+), 5 deletions(-)

Reviewed-by: Will Deacon <will.deacon@arm.com>

Will

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
