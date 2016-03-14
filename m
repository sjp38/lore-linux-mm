Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com [74.125.82.54])
	by kanga.kvack.org (Postfix) with ESMTP id C5F296B0005
	for <linux-mm@kvack.org>; Mon, 14 Mar 2016 17:40:26 -0400 (EDT)
Received: by mail-wm0-f54.google.com with SMTP id p65so119678056wmp.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:26 -0700 (PDT)
Received: from mail-wm0-x234.google.com (mail-wm0-x234.google.com. [2a00:1450:400c:c09::234])
        by mx.google.com with ESMTPS id jo9si29221426wjb.100.2016.03.14.14.40.25
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 14 Mar 2016 14:40:25 -0700 (PDT)
Received: by mail-wm0-x234.google.com with SMTP id n186so127098441wmn.1
        for <linux-mm@kvack.org>; Mon, 14 Mar 2016 14:40:25 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v3 0/2] mm, thp: Fix unnecessarry resource consuming in swapin
Date: Mon, 14 Mar 2016 23:40:09 +0200
Message-Id: <1457991611-6211-1-git-send-email-ebru.akagunduz@gmail.com>
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
