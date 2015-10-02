Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f181.google.com (mail-wi0-f181.google.com [209.85.212.181])
	by kanga.kvack.org (Postfix) with ESMTP id 31AA16B0291
	for <linux-mm@kvack.org>; Fri,  2 Oct 2015 09:36:07 -0400 (EDT)
Received: by wicge5 with SMTP id ge5so33698536wic.0
        for <linux-mm@kvack.org>; Fri, 02 Oct 2015 06:36:06 -0700 (PDT)
Received: from mx2.suse.de (mx2.suse.de. [195.135.220.15])
        by mx.google.com with ESMTPS id s4si13373203wjx.172.2015.10.02.06.36.04
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Fri, 02 Oct 2015 06:36:05 -0700 (PDT)
From: Vlastimil Babka <vbabka@suse.cz>
Subject: [PATCH v4 1/4] mm, documentation: clarify /proc/pid/status VmSwap limitations
Date: Fri,  2 Oct 2015 15:35:48 +0200
Message-Id: <1443792951-13944-2-git-send-email-vbabka@suse.cz>
In-Reply-To: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
References: <1443792951-13944-1-git-send-email-vbabka@suse.cz>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Jerome Marchand <jmarchan@redhat.com>, Andrew Morton <akpm@linux-foundation.org>, Hugh Dickins <hughd@google.com>
Cc: linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, Michal Hocko <mhocko@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Cyrill Gorcunov <gorcunov@openvz.org>, Randy Dunlap <rdunlap@infradead.org>, linux-s390@vger.kernel.org, Martin Schwidefsky <schwidefsky@de.ibm.com>, Heiko Carstens <heiko.carstens@de.ibm.com>, Peter Zijlstra <peterz@infradead.org>, Paul Mackerras <paulus@samba.org>, Arnaldo Carvalho de Melo <acme@kernel.org>, Oleg Nesterov <oleg@redhat.com>, Linux API <linux-api@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@yandex-team.ru>, Vlastimil Babka <vbabka@suse.cz>

The documentation for /proc/pid/status does not mention that the value of
VmSwap counts only swapped out anonymous private pages and not shmem. This is
not obvious, so document this limitation.

Signed-off-by: Vlastimil Babka <vbabka@suse.cz>
Acked-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Acked-by: Michal Hocko <mhocko@suse.com>
---
 Documentation/filesystems/proc.txt | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index a99b208..7ef50cb 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -239,6 +239,8 @@ Table 1-2: Contents of the status files (as of 4.1)
  VmPTE                       size of page table entries
  VmPMD                       size of second level page tables
  VmSwap                      size of swap usage (the number of referred swapents)
+                             by anonymous private data (shmem swap usage is not
+                             included)
  HugetlbPages                size of hugetlb memory portions
  Threads                     number of threads
  SigQ                        number of signals queued/max. number for queue
-- 
2.5.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
