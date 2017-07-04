Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id C75766B0279
	for <linux-mm@kvack.org>; Tue,  4 Jul 2017 05:35:59 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id t3so23127192wme.9
        for <linux-mm@kvack.org>; Tue, 04 Jul 2017 02:35:59 -0700 (PDT)
Received: from Galois.linutronix.de (Galois.linutronix.de. [2a01:7a0:2:106d:700::1])
        by mx.google.com with ESMTPS id 193si20435874wmw.153.2017.07.04.02.35.58
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=AES128-SHA bits=128/128);
        Tue, 04 Jul 2017 02:35:58 -0700 (PDT)
Message-Id: <20170704093232.995040438@linutronix.de>
Date: Tue, 04 Jul 2017 11:32:32 +0200
From: Thomas Gleixner <tglx@linutronix.de>
Subject: [patch V2 0/2] mm/memory_hotplug: Cure potential deadlocks vs. cpu
 hotplug lock
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org, Andrey Ryabinin <aryabinin@virtuozzo.com>, Michal Hocko <mhocko@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Vladimir Davydov <vdavydov.dev@gmail.com>, Peter Zijlstra <peterz@infradead.org>

Andrey reported a potential deadlock with the memory hotplug lock and the
cpu hotplug lock.

The following series addresses this by reworking the memory hotplug locking
and fixing up the potential deadlock scenarios.

Applies against Linus head. All preliminaries are merged there already

Thanks,

	tglx
---
 include/linux/swap.h |    1 
 mm/memory_hotplug.c  |   89 ++++++++-------------------------------------------
 mm/page_alloc.c      |    2 -
 mm/swap.c            |   11 ++++--
 4 files changed, 25 insertions(+), 78 deletions(-)



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
