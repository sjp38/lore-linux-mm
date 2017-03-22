Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 9CF926B0038
	for <linux-mm@kvack.org>; Wed, 22 Mar 2017 14:29:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id o126so366310545pfb.2
        for <linux-mm@kvack.org>; Wed, 22 Mar 2017 11:29:20 -0700 (PDT)
Received: from mailout4.w1.samsung.com (mailout4.w1.samsung.com. [210.118.77.14])
        by mx.google.com with ESMTPS id g64si457060pfj.10.2017.03.22.11.29.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 22 Mar 2017 11:29:19 -0700 (PDT)
Received: from eucas1p2.samsung.com (unknown [182.198.249.207])
 by mailout4.w1.samsung.com
 (Oracle Communications Messaging Server 7.0.5.31.0 64bit (built May  5 2014))
 with ESMTP id <0ON8002UWBCSBN10@mailout4.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 22 Mar 2017 18:29:16 +0000 (GMT)
From: Alexey Perevalov <a.perevalov@samsung.com>
Subject: [PATCH v2] Illuminate thread id to user space
Date: Wed, 22 Mar 2017 21:29:05 +0300
Message-id: <1490207346-9703-1-git-send-email-a.perevalov@samsung.com>
References: 
 <CGME20170322182915eucas1p1e82e604ec8a37d6cd82fdccabe173b87@eucas1p1.samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: "Dr . David Alan Gilbert" <dgilbert@redhat.com>, linux-mm@kvack.org, i.maximets@samsung.com, a.perevalov@samsung.com

Hi Andrea,

This is updated patch, difference since previous version is following:
 - process thread id is provided only when it was requested with
UFFD_FEATURE_THREAD_ID bit.
 - pid from namespace is provided, so locking thread's gettid in namespace
and msg.arg.pagefault.ptid will be equal. 
 - current patch is based on
git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault
branch too, but rebased.

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
