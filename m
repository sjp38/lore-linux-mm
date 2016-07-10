Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id 72C816B0005
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 20:07:29 -0400 (EDT)
Received: by mail-wm0-f70.google.com with SMTP id o80so3794793wme.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:07:29 -0700 (PDT)
Received: from mail-wm0-x229.google.com (mail-wm0-x229.google.com. [2a00:1450:400c:c09::229])
        by mx.google.com with ESMTPS id e132si5184781wme.59.2016.07.09.17.07.28
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 17:07:28 -0700 (PDT)
Received: by mail-wm0-x229.google.com with SMTP id o80so7823123wme.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 17:07:28 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [RFC PATCH v3 0/2] mm, thp: convert from optimistic swapin collapsing to conservative
Date: Sun, 10 Jul 2016 03:07:04 +0300
Message-Id: <1468109224-29912-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series fixes comment inconsistency and supplies to decide
to swapin looking the amount of young pages.

Changes in v2:
 - Don't change thp design, notice young pages
   if needs to swapin
 - Add comment line fixing patch

Changes in v3:
 - Remove revert patch (allocstall), the patch automatically
   dropped
 - Set comment line fixing patch as first part of the series
 - Move changes from huge_memory.c to khugepaged.c

Ebru Akagunduz (2):
  mm, thp: fix comment inconsistency for swapin readahead functions
  mm, thp: convert from optimistic swapin collapsing to conservative

 include/trace/events/huge_memory.h | 19 +++++++++-------
 mm/khugepaged.c                    | 45 +++++++++++++++++++++++---------------
 2 files changed, 38 insertions(+), 26 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
