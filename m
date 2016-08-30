Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f71.google.com (mail-pa0-f71.google.com [209.85.220.71])
	by kanga.kvack.org (Postfix) with ESMTP id C29A782F64
	for <linux-mm@kvack.org>; Tue, 30 Aug 2016 07:00:22 -0400 (EDT)
Received: by mail-pa0-f71.google.com with SMTP id ag5so32135910pad.2
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:22 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id u3si44752304pab.162.2016.08.30.04.00.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 30 Aug 2016 04:00:21 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id y134so1004747pfg.3
        for <linux-mm@kvack.org>; Tue, 30 Aug 2016 04:00:21 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 0/4] mm: mlock: fix some locked_vm counting issues
Date: Tue, 30 Aug 2016 18:59:37 +0800
Message-Id: <1472554781-9835-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Alexey Klimov <klimov.linux@gmail.com>, Andrew Morton <akpm@linux-foundation.org>, Eric B Munson <emunson@akamai.com>, Geert Uytterhoeven <geert@linux-m68k.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org, Mel Gorman <mgorman@techsingularity.net>, Michal Hocko <mhocko@suse.com>, Shuah Khan <shuah@kernel.org>, Simon Guo <wei.guo.simon@gmail.com>, Thierry Reding <treding@nvidia.com>, Vlastimil Babka <vbabka@suse.cz>

From: Simon Guo <wei.guo.simon@gmail.com>

This patch set fixes some mlock() misbehavior when mlock()/mlock2() 
is invoked multiple times on intersect or same address regions.

And add selftest for this case.

Simon Guo (4):
  mm: mlock: check against vma for actual mlock() size
  mm: mlock: avoid increase mm->locked_vm on mlock() when already
    mlock2(,MLOCK_ONFAULT)
  selftest: split mlock2_ apis into separate mlock2.h
  selftests/vm: add test for mlock() when areas are intersected.

 mm/mlock.c                                        | 53 ++++++++++++++++
 tools/testing/selftests/vm/.gitignore             |  1 +
 tools/testing/selftests/vm/Makefile               |  4 ++
 tools/testing/selftests/vm/mlock-intersect-test.c | 76 +++++++++++++++++++++++
 tools/testing/selftests/vm/mlock2-tests.c         | 21 +------
 tools/testing/selftests/vm/mlock2.h               | 21 +++++++
 6 files changed, 156 insertions(+), 20 deletions(-)
 create mode 100644 tools/testing/selftests/vm/mlock-intersect-test.c
 create mode 100644 tools/testing/selftests/vm/mlock2.h

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
