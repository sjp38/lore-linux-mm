Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f53.google.com (mail-pa0-f53.google.com [209.85.220.53])
	by kanga.kvack.org (Postfix) with ESMTP id 748CC6B0035
	for <linux-mm@kvack.org>; Mon,  4 Nov 2013 18:37:03 -0500 (EST)
Received: by mail-pa0-f53.google.com with SMTP id kx10so7552211pab.26
        for <linux-mm@kvack.org>; Mon, 04 Nov 2013 15:37:03 -0800 (PST)
Received: from psmtp.com ([74.125.245.192])
        by mx.google.com with SMTP id pz2si11966435pac.289.2013.11.04.15.37.01
        for <linux-mm@kvack.org>;
        Mon, 04 Nov 2013 15:37:02 -0800 (PST)
Subject: [PATCH 0/4] MCS Lock: MCS lock code cleanup and optimizations
From: Tim Chen <tim.c.chen@linux.intel.com>
References: <cover.1383604526.git.tim.c.chen@linux.intel.com>
Content-Type: text/plain; charset="UTF-8"
Date: Mon, 04 Nov 2013 15:36:56 -0800
Message-ID: <1383608216.11046.259.camel@schen9-DESK>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Ingo Molnar <mingo@elte.hu>, Andrew Morton <akpm@linux-foundation.org>, Thomas Gleixner <tglx@linutronix.de>
Cc: linux-kernel@vger.kernel.org, linux-mm <linux-mm@kvack.org>, linux-arch@vger.kernel.org, Linus Torvalds <torvalds@linux-foundation.org>, Waiman Long <waiman.long@hp.com>, Andrea Arcangeli <aarcange@redhat.com>, Alex Shi <alex.shi@linaro.org>, Andi Kleen <andi@firstfloor.org>, Michel Lespinasse <walken@google.com>, Davidlohr Bueso <davidlohr.bueso@hp.com>, Matthew R Wilcox <matthew.r.wilcox@intel.com>, Dave Hansen <dave.hansen@intel.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Rik van Riel <riel@redhat.com>, Peter Hurley <peter@hurleysoftware.com>, "Paul
 E.McKenney" <paulmck@linux.vnet.ibm.com>, Tim Chen <tim.c.chen@linux.intel.com>, Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>, George Spelvin <linux@horizon.com>, "H. Peter Anvin" <hpa@zytor.com>, Arnd Bergmann <arnd@arndb.de>, Aswin Chandramouleeswaran <aswin@hp.com>, Scott J Norton <scott.norton@hp.com>

In this patch series, we separated out the MCS lock code which was previously embedded in the
mutex.c.  This allows for easier reuse of MCS lock in other places like rwsem and qrwlock.
We also did some micro optimizations and barrier cleanup.

This patches were previously part of the rwsem optimization patch series but now we spearate
them out.

Tim Chen

Jason Low (2):
  MCS Lock: optimizations and extra comments
  MCS Lock: Barrier corrections

Tim Chen (1):
  MCS Lock: Restructure the MCS lock defines and locking code into its
    own file

Waiman Long (1):
  MCS Lock: Make mcs_spinlock.h includable in other files

 include/linux/mcs_spinlock.h |  100 ++++++++++++++++++++++++++++++++++++++++++
 include/linux/mutex.h        |    5 +-
 kernel/Makefile              |    6 +-
 kernel/mcs_spinlock.c        |   37 +++++++++++++++
 kernel/mutex.c               |   60 +++----------------------
 5 files changed, 150 insertions(+), 58 deletions(-)
 create mode 100644 include/linux/mcs_spinlock.h
 create mode 100644 kernel/mcs_spinlock.c

-- 
1.7.4.4


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
