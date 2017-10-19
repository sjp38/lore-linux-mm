Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7FBBE6B0069
	for <linux-mm@kvack.org>; Thu, 19 Oct 2017 01:55:35 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id g75so5011385pfg.4
        for <linux-mm@kvack.org>; Wed, 18 Oct 2017 22:55:35 -0700 (PDT)
Received: from lgeamrelo12.lge.com (LGEAMRELO12.lge.com. [156.147.23.52])
        by mx.google.com with ESMTP id o6si9000039plh.437.2017.10.18.22.55.33
        for <linux-mm@kvack.org>;
        Wed, 18 Oct 2017 22:55:34 -0700 (PDT)
From: Byungchul Park <byungchul.park@lge.com>
Subject: [PATCH v2 0/3] crossrelease: make it not unwind by default
Date: Thu, 19 Oct 2017 14:55:28 +0900
Message-Id: <1508392531-11284-1-git-send-email-byungchul.park@lge.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: peterz@infradead.org, mingo@kernel.org
Cc: tglx@linutronix.de, linux-kernel@vger.kernel.org, linux-mm@kvack.org, kernel-team@lge.com

Change from v1
- Fix kconfig description as Ingo suggested
- Fix commit message writing out CONFIG_ variable
- Introduce a new kernel parameter, crossrelease_fullstack
- Replace the number with the output of *perf*

Byungchul Park (3):
  lockdep: Introduce CROSSRELEASE_STACK_TRACE and make it not unwind as
    default
  lockdep: Remove BROKEN flag of LOCKDEP_CROSSRELEASE
  lockdep: Add a kernel parameter, crossrelease_fullstack

 Documentation/admin-guide/kernel-parameters.txt |  3 +++
 include/linux/lockdep.h                         |  4 ++++
 kernel/locking/lockdep.c                        | 23 +++++++++++++++++++++--
 lib/Kconfig.debug                               | 20 ++++++++++++++++++--
 4 files changed, 46 insertions(+), 4 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
