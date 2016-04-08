Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id C80096B007E
	for <linux-mm@kvack.org>; Fri,  8 Apr 2016 18:58:46 -0400 (EDT)
Received: by mail-wm0-f44.google.com with SMTP id n3so38858694wmn.0
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 15:58:46 -0700 (PDT)
Received: from mail-wm0-x232.google.com (mail-wm0-x232.google.com. [2a00:1450:400c:c09::232])
        by mx.google.com with ESMTPS id up10si15487875wjc.216.2016.04.08.15.58.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 08 Apr 2016 15:58:45 -0700 (PDT)
Received: by mail-wm0-x232.google.com with SMTP id l6so80624884wml.1
        for <linux-mm@kvack.org>; Fri, 08 Apr 2016 15:58:45 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v6 0/2] mm, thp: Fix unnecessarry resource consuming in swapin
Date: Sat,  9 Apr 2016 01:58:16 +0300
Message-Id: <1460156296-6504-1-git-send-email-ebru.akagunduz@gmail.com>
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
