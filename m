Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl0-f72.google.com (mail-pl0-f72.google.com [209.85.160.72])
	by kanga.kvack.org (Postfix) with ESMTP id 04EF26B039E
	for <linux-mm@kvack.org>; Wed,  9 May 2018 04:24:06 -0400 (EDT)
Received: by mail-pl0-f72.google.com with SMTP id d9-v6so3357104plj.4
        for <linux-mm@kvack.org>; Wed, 09 May 2018 01:24:05 -0700 (PDT)
Received: from mga14.intel.com (mga14.intel.com. [192.55.52.115])
        by mx.google.com with ESMTPS id 32-v6si14910130plc.252.2018.05.09.01.24.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 09 May 2018 01:24:04 -0700 (PDT)
From: "Huang, Ying" <ying.huang@intel.com>
Subject: [PATCH -mm] mm, THP, doc: Add document for thp_swpout/thp_swpout_fallback
Date: Wed,  9 May 2018 16:23:41 +0800
Message-Id: <20180509082341.13953-1-ying.huang@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Jonathan Corbet <corbet@lwn.net>
Cc: linux-mm@kvack.org, linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org, Huang Ying <ying.huang@intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Andrea Arcangeli <aarcange@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>

From: Huang Ying <ying.huang@intel.com>

Add document for newly added thp_swpout, thp_swpout_fallback fields in
/proc/vmstat.

Signed-off-by: "Huang, Ying" <ying.huang@intel.com>
Cc: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>
Cc: Johannes Weiner <hannes@cmpxchg.org>
---
 Documentation/vm/transhuge.rst | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/Documentation/vm/transhuge.rst b/Documentation/vm/transhuge.rst
index 569d182cc973..2c6867fca6ff 100644
--- a/Documentation/vm/transhuge.rst
+++ b/Documentation/vm/transhuge.rst
@@ -355,6 +355,15 @@ thp_zero_page_alloc_failed
 	is incremented if kernel fails to allocate
 	huge zero page and falls back to using small pages.
 
+thp_swpout
+	is incremented every time a huge page is swapout in one
+	piece without splitting.
+
+thp_swpout_fallback
+	is incremented if a huge page has to be split before swapout.
+	Usually because failed to allocate some continuous swap space
+	for the huge page.
+
 As the system ages, allocating huge pages may be expensive as the
 system uses memory compaction to copy data around memory to free a
 huge page for use. There are some counters in ``/proc/vmstat`` to help
-- 
2.16.1
