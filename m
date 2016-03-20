Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C531A6B0262
	for <linux-mm@kvack.org>; Sun, 20 Mar 2016 14:08:13 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id l68so127598969wml.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:08:13 -0700 (PDT)
Received: from mail-wm0-x244.google.com (mail-wm0-x244.google.com. [2a00:1450:400c:c09::244])
        by mx.google.com with ESMTPS id ci16si27295719wjb.126.2016.03.20.11.08.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 20 Mar 2016 11:08:12 -0700 (PDT)
Received: by mail-wm0-x244.google.com with SMTP id x188so17122170wmg.0
        for <linux-mm@kvack.org>; Sun, 20 Mar 2016 11:08:12 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v4 0/2] mm, thp: Fix unnecessarry resource consuming in swapin
Date: Sun, 20 Mar 2016 20:07:37 +0200
Message-Id: <1458497259-12753-1-git-send-email-ebru.akagunduz@gmail.com>
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
 mm/huge_memory.c       | 13 +++++++++++--
 mm/vmstat.c            | 12 ++++++++++++
 3 files changed, 29 insertions(+), 2 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
