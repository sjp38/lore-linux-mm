Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f70.google.com (mail-vk0-f70.google.com [209.85.213.70])
	by kanga.kvack.org (Postfix) with ESMTP id 9ABC86B02D6
	for <linux-mm@kvack.org>; Mon, 11 Sep 2017 11:48:47 -0400 (EDT)
Received: by mail-vk0-f70.google.com with SMTP id j189so5804376vka.0
        for <linux-mm@kvack.org>; Mon, 11 Sep 2017 08:48:47 -0700 (PDT)
Received: from aserp1040.oracle.com (aserp1040.oracle.com. [141.146.126.69])
        by mx.google.com with ESMTPS id 9si4954035uar.88.2017.09.11.08.48.45
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 11 Sep 2017 08:48:46 -0700 (PDT)
From: "Liam R. Howlett" <Liam.Howlett@Oracle.com>
Subject: [RFC Patch 0/1] Change OOM message from hugetlb to include requested size
Date: Mon, 11 Sep 2017 11:48:19 -0400
Message-Id: <20170911154820.16203-1-Liam.Howlett@Oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@suse.com>, Mike Kravetz <mike.kravetz@Oracle.com>, Andrea Arcangeli <aarcange@redhat.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Gerald Schaefer <gerald.schaefer@de.ibm.com>, zhong jiang <zhongjiang@huawei.com>, Hillf Danton <hillf.zj@alibaba-inc.com>, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>, linux-kernel@vger.kernel.org

This is an attempt to better highlight misconfigured huge pages by showing the
user what was requested verses what was configured.  Moving the messages within
the OOM report will make the configuration or misconfiguration more clear when
an out of memory event occurs.  The previous message has been removed in favour
of this method.

Liam R. Howlett (1):
  mm/hugetlb: Clarify OOM message on size of hugetlb and requested
    hugepages total

 include/linux/hugetlb.h |  1 +
 mm/hugetlb.c            | 35 +++++++++++++++++++++++++++++++----
 2 files changed, 32 insertions(+), 4 deletions(-)

-- 
2.14.1.145.gb3622a4ee

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
