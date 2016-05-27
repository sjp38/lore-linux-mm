Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f72.google.com (mail-wm0-f72.google.com [74.125.82.72])
	by kanga.kvack.org (Postfix) with ESMTP id B73F56B007E
	for <linux-mm@kvack.org>; Fri, 27 May 2016 03:59:37 -0400 (EDT)
Received: by mail-wm0-f72.google.com with SMTP id f75so56953312wmf.2
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:59:37 -0700 (PDT)
Received: from mail-wm0-x242.google.com (mail-wm0-x242.google.com. [2a00:1450:400c:c09::242])
        by mx.google.com with ESMTPS id j16si10578780wmi.23.2016.05.27.00.59.36
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 27 May 2016 00:59:36 -0700 (PDT)
Received: by mail-wm0-x242.google.com with SMTP id n129so11904744wmn.1
        for <linux-mm@kvack.org>; Fri, 27 May 2016 00:59:36 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH v2 0/3] mm, thp: remove duplication and fix locking issues in swapin
Date: Fri, 27 May 2016 10:59:21 +0300
Message-Id: <1464335964-6510-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series removes duplication of included header
and fixes locking inconsistency in khugepaged swapin.

Ebru Akagunduz (3):
  mm, thp: remove duplication of included header
  mm, thp: fix possible circular locking dependency caused by
    sum_vm_event()
  mm, thp: make swapin readahead under down_read of mmap_sem

 mm/huge_memory.c | 101 +++++++++++++++++++++++++++++++++++++------------------
 1 file changed, 68 insertions(+), 33 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
