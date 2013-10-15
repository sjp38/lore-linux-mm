Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f180.google.com (mail-pd0-f180.google.com [209.85.192.180])
	by kanga.kvack.org (Postfix) with ESMTP id B585C6B0031
	for <linux-mm@kvack.org>; Tue, 15 Oct 2013 13:16:59 -0400 (EDT)
Received: by mail-pd0-f180.google.com with SMTP id y10so9123005pdj.39
        for <linux-mm@kvack.org>; Tue, 15 Oct 2013 10:16:59 -0700 (PDT)
From: Toshi Kani <toshi.kani@hp.com>
Subject: [PATCH 0/2] mm: Fix N_CPU handlings of node_states
Date: Tue, 15 Oct 2013 11:12:54 -0600
Message-Id: <1381857176-22999-1-git-send-email-toshi.kani@hp.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, cl@linux-foundation.org, isimatu.yasuaki@jp.fujitsu.com, Toshi Kani <toshi.kani@hp.com>

node_stats[N_CPU] tracks which nodes have CPUs on the system.
vmstat.c updates this N_CPU information, but it has multiple
issues. 

Patch 1/2 changes setup_vmstat() to set up the N_CPU info at
boot.  Patch 2/2 changes vmstat_cpuup_callback() to udpate
the N_CPU info at CPU offline.

---
Toshi Kani (2)
  mm: Set N_CPU to node_states during boot
  mm: Clear N_CPU from node_states at CPU offline

---
 mm/vmstat.c | 21 ++++++++++++++++++++-
 1 file changed, 20 insertions(+), 1 deletion(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
