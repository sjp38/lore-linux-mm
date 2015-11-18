Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f42.google.com (mail-wm0-f42.google.com [74.125.82.42])
	by kanga.kvack.org (Postfix) with ESMTP id 562046B027A
	for <linux-mm@kvack.org>; Wed, 18 Nov 2015 04:30:05 -0500 (EST)
Received: by wmvv187 with SMTP id v187so268240224wmv.1
        for <linux-mm@kvack.org>; Wed, 18 Nov 2015 01:30:04 -0800 (PST)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id y84si5864807wmb.115.2015.11.18.01.29.56
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 18 Nov 2015 01:29:56 -0800 (PST)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v5 1/6] mm, documentation: clarify /proc/pid/status VmSwap limitations for shmem
Date: Wed, 18 Nov 2015 10:29:31 +0100
Message-Id: <1447838976-17607-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
References: <1447838976-17607-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, Jerome Marchand <jmarchan@redhat.com>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, Peter Zijlstra <peterz@infradead.org>, Oleg Nesterov <oleg@redhat.com>, linux-api@vger.kernel.org, linux-doc@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Michal Hocko <mhocko@suse.com>

The documentation for /proc/pid/status does not mention that the value of
VmSwap counts only swapped out anonymous private pages, and not swapped out
pages of the underlying shmem objects (for shmem mappings). This is not
obvious, so document this limitation.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
Acked-by: Jerome Marchand <jmarchan@redhat.com>
Acked-by: Hugh Dickins <hughd@google.com>
---
 Documentation/filesystems/proc.txt | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 402ab99..9f13b6e 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -238,7 +238,8 @@ Table 1-2: Contents of the status files (as of 4.1)
  VmLib                       size of shared library code
  VmPTE                       size of page table entries
  VmPMD                       size of second level page tables
- VmSwap                      size of swap usage (the number of referred swapents)
+ VmSwap                      amount of swap used by anonymous private data
+                             (shmem swap usage is not included)
  HugetlbPages                size of hugetlb memory portions
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
-- 
2.6.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
