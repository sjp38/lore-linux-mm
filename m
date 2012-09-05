Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx207.postini.com [74.125.245.207])
	by kanga.kvack.org (Postfix) with SMTP id B15B96B0068
	for <linux-mm@kvack.org>; Wed,  5 Sep 2012 07:13:12 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] srcu mmu_notifier cleanup
Date: Wed,  5 Sep 2012 13:12:36 +0200
Message-Id: <1346843557-499-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Xiao Guangrong <xiaoguangrong@linux.vnet.ibm.com>, Sagi Grimberg <sagig@mellanox.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>, Haggai Eran <haggaie@mellanox.com>

Hi Andrew,

while re-reading the code, I found an easy to overlook but badly
needed cleanup in the mmu notifier srcu patch.

We can't allow such a generic name to be non static (even if it works
fine at this time). Plus here "static" is so much better regardless of
the name.

This is incremental but feel free to fold this on onto the prev srcu
patch.

Thanks,
Andrea

Andrea Arcangeli (1):
  mm: mmu_notifier: make the mmu_notifier srcu static

 mm/mmu_notifier.c |    6 +++---
 1 files changed, 3 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
