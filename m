Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lb0-f198.google.com (mail-lb0-f198.google.com [209.85.217.198])
	by kanga.kvack.org (Postfix) with ESMTP id 21F5A6B0005
	for <linux-mm@kvack.org>; Mon, 23 May 2016 13:14:42 -0400 (EDT)
Received: by mail-lb0-f198.google.com with SMTP id rs7so67801085lbb.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:42 -0700 (PDT)
Received: from mail-wm0-x243.google.com (mail-wm0-x243.google.com. [2a00:1450:400c:c09::243])
        by mx.google.com with ESMTPS id c5si45473913wjw.199.2016.05.23.10.14.40
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 23 May 2016 10:14:40 -0700 (PDT)
Received: by mail-wm0-x243.google.com with SMTP id f75so10745038wmf.2
        for <linux-mm@kvack.org>; Mon, 23 May 2016 10:14:40 -0700 (PDT)
From: Ebru Akagunduz <ebru.akagunduz@gmail.com>
Subject: [PATCH 0/3] mm, thp: remove duplication and fix locking issues in swapin
Date: Mon, 23 May 2016 20:14:08 +0300
Message-Id: <1464023651-19420-1-git-send-email-ebru.akagunduz@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: hughd@google.com, riel@redhat.com, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, n-horiguchi@ah.jp.nec.com, aarcange@redhat.com, iamjoonsoo.kim@lge.com, gorcunov@openvz.org, linux-kernel@vger.kernel.org, mgorman@suse.de, rientjes@google.com, vbabka@suse.cz, aneesh.kumar@linux.vnet.ibm.com, hannes@cmpxchg.org, mhocko@suse.cz, boaz@plexistor.com, Ebru Akagunduz <ebru.akagunduz@gmail.com>

This patch series removes duplication of included header
and fixes locking inconsistency in khugepaged swapin

Ebru Akagunduz (3):
  mm, thp: remove duplication of included header
  mm, thp: fix possible circular locking dependency caused by
    sum_vm_event()
  mm, thp: make swapin readahead under down_read of mmap_sem

 mm/huge_memory.c | 39 ++++++++++++++++++++++++++++++---------
 1 file changed, 30 insertions(+), 9 deletions(-)

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
