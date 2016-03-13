Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f46.google.com (mail-wm0-f46.google.com [74.125.82.46])
	by kanga.kvack.org (Postfix) with ESMTP id 0DDE46B0005
	for <linux-mm@kvack.org>; Sun, 13 Mar 2016 05:29:12 -0400 (EDT)
Received: by mail-wm0-f46.google.com with SMTP id l68so67068759wml.1
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 01:29:11 -0800 (PST)
Received: from mail-wm0-x235.google.com (mail-wm0-x235.google.com. [2a00:1450:400c:c09::235])
        by mx.google.com with ESMTPS id 128si12401096wmg.38.2016.03.13.01.29.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sun, 13 Mar 2016 01:29:11 -0800 (PST)
Received: by mail-wm0-x235.google.com with SMTP id n186so70279364wmn.1
        for <linux-mm@kvack.org>; Sun, 13 Mar 2016 01:29:10 -0800 (PST)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v2 0/2] mm, thp: Fix unnecessarry resource consuming in swapin
Date: Sun, 13 Mar 2016 11:28:53 +0200
Message-Id: <1457861335-23297-1-git-send-email-ebru.akagunduz@gmail.com>
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

 include/linux/vmstat.h |  2 ++
 mm/huge_memory.c       | 13 +++++++++++--
 mm/vmstat.c            | 12 ++++++++++++
 3 files changed, 25 insertions(+), 2 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
