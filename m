Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f169.google.com (mail-wi0-f169.google.com [209.85.212.169])
	by kanga.kvack.org (Postfix) with ESMTP id 9DFB59003C8
	for <linux-mm@kvack.org>; Wed,  5 Aug 2015 09:02:29 -0400 (EDT)
Received: by wicgj17 with SMTP id gj17so191574740wic.1
        for <linux-mm@kvack.org>; Wed, 05 Aug 2015 06:02:29 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id wu10si5573934wjb.190.2015.08.05.06.02.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 05 Aug 2015 06:02:19 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v3 1/4] mm, documentation: clarify /proc/pid/status VmSwap limitations
Date: Wed,  5 Aug 2015 15:01:22 +0200
Message-Id: <1438779685-5227-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
References: <1438779685-5227-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jerome Marchand <jmarchan@redhat.com>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Vlastimil Babka <vbabka@suse.cz>, Hugh Dickins <hughd@google.com>, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Minchan Kim <minchan@kernel.org>

The documentation for /proc/pid/status does not mention that the value of
VmSwap counts only swapped out anonymous private pages and not shmem. This is
not obvious, so document this limitation.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
---
 Documentation/filesystems/proc.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index d411ca6..29f4011 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -237,6 +237,8 @@ Table 1-2: Contents of the status files (as of 4.1)
  VmPTE                       size of page table entries
  VmPMD                       size of second level page tables
  VmSwap                      size of swap usage (the number of referred swapents)
+                             by anonymous private data (shmem swap usage is not
+                             included)
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
  SigPnd                      bitmap of pending signals for the thread
-- 
2.4.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
