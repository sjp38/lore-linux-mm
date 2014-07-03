Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 434306B0031
	for <linux-mm@kvack.org>; Thu,  3 Jul 2014 17:53:33 -0400 (EDT)
Received: by mail-wi0-f172.google.com with SMTP id hi2so12153901wib.17
        for <linux-mm@kvack.org>; Thu, 03 Jul 2014 14:53:32 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id u2si24425092wjx.135.2014.07.03.14.53.30
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 Jul 2014 14:53:31 -0700 (PDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/4] mm: introduce fincore() v2
Date: Thu,  3 Jul 2014 17:52:11 -0400
Message-Id: <1404424335-30128-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Konstantin Khlebnikov <koct9i@gmail.com>, Wu Fengguang <fengguang.wu@intel.com>, Arnaldo Carvalho de Melo <acme@redhat.com>, Borislav Petkov <bp@alien8.de>, "Kirill A. Shutemov" <kirill@shutemov.name>, Johannes Weiner <hannes@cmpxchg.org>, Rusty Russell <rusty@rustcorp.com.au>, David Miller <davem@davemloft.net>, Andres Freund <andres@2ndquadrant.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Dave Hansen <dave.hansen@intel.com>, Christoph Hellwig <hch@infradead.org>, Michael Kerrisk <mtk.manpages@gmail.com>, Linux API <linux-api@vger.kernel.org>, Naoya Horiguchi <nao.horiguchi@gmail.com>

This is the 2nd version of fincore patchset.

In the previous discussion[1], I got many feedbacks about the following
points:
- robust ABI handling is needed (especially about PAGECACHE_TAG_*)
- man page is necessary
- the parameter/return value of sys_fincore() needs improvement
- the order of bits FINCORE_*  and the order of 8 bytes entry in buffer
  should be identical
so I covered these in this version.

Any comments/reviews are welcomed.

[1] http://lwn.net/Articles/601020/

Thanks,
Naoya Horiguchi
---
Tree: git@github.com:Naoya-Horiguchi/linux.git
Branch: v3.16-rc3/fincore.ver2
---
Summary:

Naoya Horiguchi (4):
      define PAGECACHE_TAG_* as enumeration under include/uapi
      mm: introduce fincore()
      selftests/fincore: add test code for fincore()
      man2/fincore.2: document general description about fincore(2)

 arch/x86/syscalls/syscall_64.tbl                   |   1 +
 include/linux/fs.h                                 |   9 +-
 include/linux/syscalls.h                           |   4 +
 include/uapi/linux/pagecache.h                     | 111 ++++++
 man2/fincore.2                                     | 383 ++++++++++++++++++++
 mm/Makefile                                        |   2 +-
 mm/fincore.c                                       | 322 +++++++++++++++++
 tools/testing/selftests/Makefile                   |   1 +
 tools/testing/selftests/fincore/Makefile           |  31 ++
 .../selftests/fincore/create_hugetlbfs_file.c      |  49 +++
 tools/testing/selftests/fincore/fincore.c          | 166 +++++++++
 tools/testing/selftests/fincore/run_fincoretests   | 401 +++++++++++++++++++++
 12 files changed, 1471 insertions(+), 9 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
