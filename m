Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 2713E6B0005
	for <linux-mm@kvack.org>; Thu,  7 Apr 2016 13:24:48 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id u206so96412871wme.1
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:24:48 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id c65si31134942wmd.107.2016.04.07.10.24.46
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Apr 2016 10:24:46 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id f198so34668846wme.0
        for <linux-mm@kvack.org>; Thu, 07 Apr 2016 10:24:46 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v5 0/2] mm, thp: Fix unnecessarry resource consuming in swapin
Date: Thu,  7 Apr 2016 20:24:21 +0300
Message-Id: <1460049861-10646-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series fixes unnecessarry resource consuming
in khugepaged swapin and introduces a new function to
calculate value of specific vm event.

Ebru Akagunduz (2):
  mm, vmstat: calculate particular vm event
  mm, thp: avoid unnecessary swapin in khugepaged

 include/linux/vmstat.h |  6 ++++++
 mm/huge_memory.c       | 18 +++++++++++++++---
 mm/vmstat.c            | 12 ++++++++++++
 3 files changed, 33 insertions(+), 3 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
