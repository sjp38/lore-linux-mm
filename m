Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 02E0D6B04BE
	for <linux-mm@kvack.org>; Fri,  8 Sep 2017 17:56:25 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id v82so6791121pgb.5
        for <linux-mm@kvack.org>; Fri, 08 Sep 2017 14:56:24 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTPS id h63si2074838pgc.833.2017.09.08.14.56.23
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Sep 2017 14:56:23 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] x86: Fix performance regression in get_user_pages_fast()
Date: Sat,  9 Sep 2017 00:56:01 +0300
Message-Id: <20170908215603.9189-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>, Ingo Molnar <mingo@kernel.org>
Cc: x86@kernel.org, Thorsten Leemhuis <regressions@leemhuis.info>, Jonathan Corbet <corbet@lwn.net>, Huang Ying <ying.huang@intel.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Fix performance regression found by 0-day.

Kirill A. Shutemov (2):
  mm: Add infrastructure for get_user_pages_fast() benchmarking
  mm, x86: Fix performance regression in get_user_pages_fast()

 mm/Kconfig                                 |   9 +++
 mm/Makefile                                |   1 +
 mm/gup.c                                   |  97 +++++++++++++++++-----------
 mm/gup_benchmark.c                         | 100 +++++++++++++++++++++++++++++
 tools/testing/selftests/vm/Makefile        |   1 +
 tools/testing/selftests/vm/gup_benchmark.c |  91 ++++++++++++++++++++++++++
 6 files changed, 260 insertions(+), 39 deletions(-)
 create mode 100644 mm/gup_benchmark.c
 create mode 100644 tools/testing/selftests/vm/gup_benchmark.c

-- 
2.14.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
