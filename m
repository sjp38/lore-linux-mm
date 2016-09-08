Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 294336B0038
	for <linux-mm@kvack.org>; Thu,  8 Sep 2016 05:13:20 -0400 (EDT)
Received: by mail-pf0-f198.google.com with SMTP id v67so101307281pfv.1
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:20 -0700 (PDT)
Received: from mail-pa0-x231.google.com (mail-pa0-x231.google.com. [2607:f8b0:400e:c03::231])
        by mx.google.com with ESMTPS id m6si5012021pay.162.2016.09.08.02.13.19
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 08 Sep 2016 02:13:19 -0700 (PDT)
Received: by mail-pa0-x231.google.com with SMTP id id6so15579280pad.3
        for <linux-mm@kvack.org>; Thu, 08 Sep 2016 02:13:19 -0700 (PDT)
From: wei.guo.simon@gmail.com
Subject: [PATCH 0/3] mm: mlock: elaborate mlock selftest case and fix one bug identified
Date: Thu,  8 Sep 2016 17:12:47 +0800
Message-Id: <1473325970-11393-1-git-send-email-wei.guo.simon@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Shuah Khan <shuah@kernel.org>, Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Michal Hocko <mhocko@suse.com>, Eric B Munson <emunson@akamai.com>, Simon Guo <wei.guo.simon@gmail.com>, Mel Gorman <mgorman@techsingularity.net>, Alexey Klimov <klimov.linux@gmail.com>, Andrea Arcangeli <aarcange@redhat.com>, Thierry Reding <treding@nvidia.com>, Mike Kravetz <mike.kravetz@oracle.com>, Geert Uytterhoeven <geert@linux-m68k.org>, linux-kernel@vger.kernel.org, linux-kselftest@vger.kernel.org

From: Simon Guo <wei.guo.simon@gmail.com>

The original mlock self tests are far from completed and David suggests
to elaborate that.

The patch set expand mlock selftest case by randomly mlock/mlock2 on
given memory region. It covers both under MLOCK rlimit and exceed MLOCK 
rlimit case.

During the testing, one bug was identified (introduced by my previous patch 
and sorry for that). Fix is included in this patch set.

Simon Guo (3):
  mm: mlock: correct a typo in count_mm_mlocked_page_nr() for caculate
    VMLOCKED pages
  selftest: move seek_to_smaps_entry() out of mlock2-tests.c
  selftests: expanding more mlock selftest

 mm/mlock.c                                        |   6 +-
 tools/testing/selftests/vm/Makefile               |   4 +-
 tools/testing/selftests/vm/mlock-intersect-test.c |  76 ------
 tools/testing/selftests/vm/mlock-random-test.c    | 293 ++++++++++++++++++++++
 tools/testing/selftests/vm/mlock2-tests.c         |  42 ----
 tools/testing/selftests/vm/mlock2.h               |  43 ++++
 6 files changed, 342 insertions(+), 122 deletions(-)
 delete mode 100644 tools/testing/selftests/vm/mlock-intersect-test.c
 create mode 100644 tools/testing/selftests/vm/mlock-random-test.c

-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
