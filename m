Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id A82E46B0038
	for <linux-mm@kvack.org>; Thu,  2 Mar 2017 00:25:45 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id 67so71947831pfg.0
        for <linux-mm@kvack.org>; Wed, 01 Mar 2017 21:25:45 -0800 (PST)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id a68si377856pfg.49.2017.03.01.21.25.44
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Mar 2017 21:25:44 -0800 (PST)
From: Pavel Tatashin <pasha.tatashin@oracle.com>
Subject: [PATCH v3 0/4] Zeroing hash tables in allocator
Date: Thu,  2 Mar 2017 00:33:41 -0500
Message-Id: <1488432825-92126-1-git-send-email-pasha.tatashin@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, sparclinux@vger.kernel.org, linux-fsdevel@vger.kernel.org

Changes:
v3 -> v2: Added a new patch for adaptive hash table scaling as suggested by
Andi Kleen
v1 -> v2: Reverted NG4memcpy() changes

Pavel Tatashin (4):
  sparc64: NG4 memset 32 bits overflow
  mm: Zeroing hash tables in allocator
  mm: Updated callers to use HASH_ZERO flag
  mm: Adaptive hash table scaling

 arch/sparc/lib/NG4memset.S          |   26 +++++++++++++-------------
 fs/dcache.c                         |   18 ++++--------------
 fs/inode.c                          |   14 ++------------
 fs/namespace.c                      |   10 ++--------
 include/linux/bootmem.h             |    2 ++
 kernel/locking/qspinlock_paravirt.h |    3 ++-
 kernel/pid.c                        |    7 ++-----
 mm/page_alloc.c                     |   31 ++++++++++++++++++++++++++++---
 8 files changed, 55 insertions(+), 56 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
