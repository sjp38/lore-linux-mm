Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f43.google.com (mail-wg0-f43.google.com [74.125.82.43])
	by kanga.kvack.org (Postfix) with ESMTP id 519E16B00DF
	for <linux-mm@kvack.org>; Wed, 12 Nov 2014 17:33:45 -0500 (EST)
Received: by mail-wg0-f43.google.com with SMTP id y10so15600441wgg.2
        for <linux-mm@kvack.org>; Wed, 12 Nov 2014 14:33:44 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id qc9si29664343wic.3.2014.11.12.14.33.43
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 12 Nov 2014 14:33:44 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 0/3] hugetlb: misc small fixes/improvements
Date: Wed, 12 Nov 2014 17:33:10 -0500
Message-Id: <1415831593-9020-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, andi@firstfloor.org, rientjes@google.com, riel@redhat.com, isimatu.yasuaki@jp.fujitsu.com, yinghai@kernel.org, davidlohr@hp.com

Hi,

This series contains three independent patches for hugetlb. The first one
is a doc fix, the second and third ones are little code improvements.

Please, check individual patches for details.

Luiz Capitulino (3):
  hugetlb: fix hugepages= entry in kernel-parameters.txt
  hugetlb: alloc_bootmem_huge_page(): use IS_ALIGNED()
  hugetlb: hugetlb_register_all_nodes(): add __init marker

 Documentation/kernel-parameters.txt | 4 +---
 mm/hugetlb.c                        | 4 ++--
 2 files changed, 3 insertions(+), 5 deletions(-)

-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
