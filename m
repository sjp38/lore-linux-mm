Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f53.google.com (mail-pb0-f53.google.com [209.85.160.53])
	by kanga.kvack.org (Postfix) with ESMTP id 8D4B86B0117
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 16:42:08 -0500 (EST)
Received: by mail-pb0-f53.google.com with SMTP id up7so103548pbc.26
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 13:42:08 -0800 (PST)
Received: from psmtp.com ([74.125.245.176])
        by mx.google.com with SMTP id bc2si521762pad.100.2013.11.06.13.42.06
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 13:42:06 -0800 (PST)
Message-ID: <1383774119.13330.2.camel@buesod1.americas.hpqcorp.net>
Subject: Re: [PATCH v3 0/4] MCS Lock: MCS lock code cleanup and optimizations
From: Davidlohr Bueso <davidlohr@hp.com>
Date: Wed, 06 Nov 2013 13:41:59 -0800
In-Reply-To: <1383773816.11046.352.camel@schen9-DESK>
References: <cover.1383771175.git.tim.c.chen@linux.intel.com>
	 <1383773816.11046.352.camel@schen9-DESK>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tim Chen <tim.c.chen@linux.intel.com>
Cc: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>, linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul E.McKenney" <paulmck@linux.vnet.ibm.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

On Wed, 2013-11-06 at 13:36 -0800, Tim Chen wrote:
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
> v3:
> 1. modified memory barriers to support non x86 architectures that have
> weak memory ordering.
> 
> v2:
> 1. change export mcs_spin_lock as a GPL export symbol
> 2. corrected mcs_spin_lock to references
> 
> 
> Jason Low (2):
>   MCS Lock: optimizations and extra comments
>   MCS Lock: Barrier corrections
> 
> 
> Jason Low (2):
>   MCS Lock: optimizations and extra comments
>   MCS Lock: Barrier corrections
> 
> Tim Chen (1):
>   MCS Lock: Restructure the MCS lock defines and locking code into its
>     own file
> 
> Waiman Long (2):
>   MCS Lock: Make mcs_spinlock.h includable in other files
>   MCS Lock: Allow architecture specific memory barrier in lock/unlock
> 
>  arch/x86/include/asm/barrier.h |    6 +++
>  include/linux/mcs_spinlock.h   |   25 ++++++++++
>  include/linux/mutex.h          |    5 +-
>  kernel/Makefile                |    6 +-
>  kernel/mcs_spinlock.c          |   96 ++++++++++++++++++++++++++++++++++++++++
>  kernel/mutex.c                 |   60 +++----------------------
>  6 files changed, 140 insertions(+), 58 deletions(-)
>  create mode 100644 include/linux/mcs_spinlock.h
>  create mode 100644 kernel/mcs_spinlock.c

Hmm I noticed that Peter's patchset to move locking mechanisms into a
unique directory is now in -tip, ie:

http://marc.info/?l=linux-kernel&m=138373682928585

So we'll have problems applying this patchset, it would probably be best
to rebase on top.

Thanks,
Davidlohr

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
