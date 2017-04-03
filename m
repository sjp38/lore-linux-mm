Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 2080E6B039F
	for <linux-mm@kvack.org>; Mon,  3 Apr 2017 05:33:13 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id m66so136723587pga.15
        for <linux-mm@kvack.org>; Mon, 03 Apr 2017 02:33:13 -0700 (PDT)
Received: from mailout3.w1.samsung.com (mailout3.w1.samsung.com. [210.118.77.13])
        by mx.google.com with ESMTPS id z78si13777284pfi.308.2017.04.03.02.33.11
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Mon, 03 Apr 2017 02:33:12 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
 by mailout3.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ONT008CCUJ89760@mailout3.w1.samsung.com> for
 linux-mm@kvack.org; Mon, 03 Apr 2017 10:33:08 +0100 (BST)
From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: [PATCH v3] Illuminate thread id to user space
Date: Mon, 03 Apr 2017 12:32:35 +0300
Message-id: <1491211956-6095-1-git-send-email-a.perevalov@samsung.com>
References: 
 <CGME20170403093307eucas1p2e1110dd2550426c53a7b8825efa34f99@eucas1p2.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>, linux-mm@kvack.org
Cc: Alexey Perevalov <a.perevalov@samsung.com>, rppt@linux.vnet.ibm.com, mike.kravetz@oracle.com, dgilbert@redhat.com


Hi Andrea,

This is third version of the patch. Modifications since previous versions:
	(v3 -> v2)
 - type of ptid now is __u32. As you suggested.

	(v2 -> v1)
 - process thread id is provided only when it was requested with
UFFD_FEATURE_THREAD_ID bit.
 - pid from namespace is provided, so locking thread's gettid in namespace
and msg.arg.pagefault.ptid will be equal. 

This patch is based on
git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault branch.
HEAD commit is "userfaultfd: switch to exclusive wakeup for blocking reads"


Alexey Perevalov (1):
  userfaultfd: provide pid in userfault msg

 fs/userfaultfd.c                 | 8 ++++++--
 include/uapi/linux/userfaultfd.h | 8 +++++++-
 2 files changed, 13 insertions(+), 3 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
