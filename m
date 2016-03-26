Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f179.google.com (mail-pf0-f179.google.com [209.85.192.179])
	by kanga.kvack.org (Postfix) with ESMTP id CACFF6B007E
	for <linux-mm@kvack.org>; Mon, 28 Mar 2016 12:42:56 -0400 (EDT)
Received: by mail-pf0-f179.google.com with SMTP id 4so141712203pfd.0
        for <linux-mm@kvack.org>; Mon, 28 Mar 2016 09:42:56 -0700 (PDT)
Received: from smtp-outbound-1.vmware.com (smtp-outbound-1.vmware.com. [208.91.2.12])
        by mx.google.com with ESMTPS id q14si21209354pfi.166.2016.03.28.09.42.55
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 28 Mar 2016 09:42:56 -0700 (PDT)
From: Nadav Amit <namit@vmware.com>
Subject: [PATCH v2 0/2] Fixes for batched TLB flushes
Date: Sat, 26 Mar 2016 01:25:03 -0700
Message-Id: <1458980705-121507-1-git-send-email-namit@vmware.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, x86@kernel.org, mgorman@suse.de, sasha.levin@oracle.com, akpm@linux-foundation.org, namit@vmware.com, riel@redhat.com, dave.hansen@linux.intel.com, luto@kernel.org, kirill.shutemov@linux.intel.com, mhocko@suse.com, jmarchan@redhat.com, hughd@google.com, vdavydov@virtuozzo.com, minchan@kernel.org, linux-kernel@vger.kernel.org

The recent introduction of batched TLB flushes causes accounting problems in
vmstat and misses some tracepoints. In addition, I am afraid it might cause
problems in some platforms (Xen, UV) since it uses non-standard APIs.

v1->v2
* Added second patch to use standard api for invalidations
* cc'ing linux-mm

Nadav Amit (2):
  x86/mm: TLB_REMOTE_SEND_IPI should count pages
  mm/rmap: batched invalidations should use existing api

 arch/x86/include/asm/tlbflush.h |  6 ------
 arch/x86/mm/tlb.c               | 14 ++++++++++----
 mm/rmap.c                       | 28 +++++++---------------------
 3 files changed, 17 insertions(+), 31 deletions(-)

-- 
2.5.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
