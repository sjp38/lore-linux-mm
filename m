Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-we0-f171.google.com (mail-we0-f171.google.com [74.125.82.171])
	by kanga.kvack.org (Postfix) with ESMTP id 6F48D6B0035
	for <linux-mm@kvack.org>; Mon, 20 Jan 2014 02:09:17 -0500 (EST)
Received: by mail-we0-f171.google.com with SMTP id w61so6463605wes.2
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 23:09:16 -0800 (PST)
Received: from mail-ee0-x22c.google.com (mail-ee0-x22c.google.com [2a00:1450:4013:c00::22c])
        by mx.google.com with ESMTPS id v8si203960wiz.76.2014.01.19.23.09.16
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Sun, 19 Jan 2014 23:09:16 -0800 (PST)
Received: by mail-ee0-f44.google.com with SMTP id c13so3204040eek.17
        for <linux-mm@kvack.org>; Sun, 19 Jan 2014 23:09:16 -0800 (PST)
Date: Mon, 20 Jan 2014 08:09:12 +0100
From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v7 4/6] MCS Lock: Barrier corrections
Message-ID: <20140120070912.GA32324@gmail.com>
References: <cover.1389890175.git.tim.c.chen@linux.intel.com>
 <1389917308.3138.14.camel@schen9-DESK>
 <20140120023322.GL10038@linux.vnet.ibm.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20140120023322.GL10038@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Cc: Tim Chen <tim.c.chen@linux.intel.com>, Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, Will Deacon <will.deacon@arm.com>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, "Figo.zhang" <figo1802@gmail.com>


* Paul E. McKenney <paulmck@linux.vnet.ibm.com> wrote:

> On Thu, Jan 16, 2014 at 04:08:28PM -0800, Tim Chen wrote:
> > This patch corrects the way memory barriers are used in the MCS lock
> > with smp_load_acquire and smp_store_release fucnction.
> > It removes ones that are not needed.
> > 
> > Note that using the smp_load_acquire/smp_store_release pair is not
> > sufficient to form a full memory barrier across
> > cpus for many architectures (except x86) for mcs_unlock and mcs_lock.
> > For applications that absolutely need a full barrier across multiple cpus
> > with mcs_unlock and mcs_lock pair, smp_mb__after_unlock_lock() should be
> > used after mcs_lock if a full memory barrier needs to be guaranteed.
> > 
> > From: Waiman Long <Waiman.Long@hp.com>
> > Suggested-by: Michel Lespinasse <walken@google.com>
> > Signed-off-by: Waiman Long <Waiman.Long@hp.com>
> > Signed-off-by: Jason Low <jason.low2@hp.com>
> > Signed-off-by: Tim Chen <tim.c.chen@linux.intel.com>
> 
> And this fixes my gripes in the first patch in this series, good!

So I'd really suggest doing fixes first in the series, code movement 
second. That will make it much easier to backport the fix to -stable, 
should the need arise.

Thanks,

	Ingo

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
