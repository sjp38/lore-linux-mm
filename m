Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pb0-f48.google.com (mail-pb0-f48.google.com [209.85.160.48])
	by kanga.kvack.org (Postfix) with ESMTP id A1D516B0130
	for <linux-mm@kvack.org>; Wed,  6 Nov 2013 20:26:50 -0500 (EST)
Received: by mail-pb0-f48.google.com with SMTP id mc8so322742pbc.21
        for <linux-mm@kvack.org>; Wed, 06 Nov 2013 17:26:50 -0800 (PST)
Received: from psmtp.com ([74.125.245.106])
        by mx.google.com with SMTP id w8si674400pbi.47.2013.11.06.17.26.47
        for <linux-mm@kvack.org>;
        Wed, 06 Nov 2013 17:26:48 -0800 (PST)
Subject: [PATCH v4 0/4] MCS Lock: MCS lock code cleanup and optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1383783691.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Wed, 06 Nov 2013 17:26:40 -0800
Message-ID: <1383787600.11046.363.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>, Will Deacon <will.deacon@arm.com>, "Figo.zhang" <figo1802@gmail.com>

In this patch series, we separated out the MCS lock code which was
previously embedded in the mutex.c.  This allows for easier reuse of
MCS lock in other places like rwsem and qrwlock.  We also did some micro
optimizations and barrier cleanup.

This patches were previously part of the rwsem optimization patch series
but now we spearate them out.

Tim Chen

v4:
1. Move patch series to the latest tip after v3.12

v3:
1. modified memory barriers to support non x86 architectures that have
weak memory ordering.

v2:
1. change export mcs_spin_lock as a GPL export symbol
2. corrected mcs_spin_lock to references


Jason Low (2):
  MCS Lock: optimizations and extra comments
  MCS Lock: Barrier corrections

Tim Chen (1):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file

Waiman Long (2):
  MCS Lock: Make mcs_spinlock.h includable in other files
  MCS Lock: Allow architecture specific memory barrier in lock/unlock

 arch/x86/include/asm/barrier.h |    6 +++
 include/linux/mcs_spinlock.h   |   25 ++++++++++
 include/linux/mutex.h          |    5 +-
 kernel/locking/Makefile        |    6 +-
 kernel/locking/mcs_spinlock.c  |   96 ++++++++++++++++++++++++++++++++++++++++
 kernel/locking/mutex.c         |   60 +++----------------------
 6 files changed, 140 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h
 create mode 100644 kernel/locking/mcs_spinlock.c

-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
