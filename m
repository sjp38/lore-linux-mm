Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ua0-f199.google.com (mail-ua0-f199.google.com [209.85.217.199])
	by kanga.kvack.org (Postfix) with ESMTP id C93446B0699
	for <linux-mm@kvack.org>; Fri, 18 May 2018 18:52:55 -0400 (EDT)
Received: by mail-ua0-f199.google.com with SMTP id y11-v6so7666084uag.16
        for <linux-mm@kvack.org>; Fri, 18 May 2018 15:52:55 -0700 (PDT)
Received: from userp2130.oracle.com (userp2130.oracle.com. [156.151.31.86])
        by mx.google.com with ESMTPS id a16-v6si3428485uae.321.2018.05.18.15.52.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 18 May 2018 15:52:54 -0700 (PDT)
From: Mike Kravetz <mike.kravetz@oracle.com>
Subject: [PATCH] MAINTAINERS: Change hugetlbfs maintainer and update files
Date: Fri, 18 May 2018 15:52:36 -0700
Message-Id: <20180518225236.19079-1-mike.kravetz@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Nadia Yvette Chambers <nyc@holomorphy.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Michal Hocko <mhocko@kernel.org>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, "Aneesh Kumar K . V" <aneesh.kumar@linux.vnet.ibm.com>, Jan Kara <jack@suse.cz>, Mike Kravetz <mike.kravetz@oracle.com>

The current hugetlbfs maintainer has not been active for more than
a few years.  I have been been active in this area for more than
two years and plan to remain active in the foreseeable future.

Also, update the hugetlbfs entry to include linux-mm mail list and
additional hugetlbfs related files.  hugetlb.c and hugetlb.h are
not 100% hugetlbfs, but a majority of their content is hugetlbfs
related.

Signed-off-by: Mike Kravetz <mike.kravetz@oracle.com>
---
 MAINTAINERS | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 9051a9ca24a2..c7a5eb074eb1 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6564,9 +6564,15 @@ F:	Documentation/networking/hinic.txt
 F:	drivers/net/ethernet/huawei/hinic/
 
 HUGETLB FILESYSTEM
-M:	Nadia Yvette Chambers <nyc@holomorphy.com>
+M:	Mike Kravetz <mike.kravetz@oracle.com>
+L:	linux-mm@kvack.org
 S:	Maintained
 F:	fs/hugetlbfs/
+F:	mm/hugetlb.c
+F:	include/linux/hugetlb.h
+F:	Documentation/admin-guide/mm/hugetlbpage.rst
+F:	Documentation/vm/hugetlbfs_reserv.rst
+F:	Documentation/ABI/testing/sysfs-kernel-mm-hugepages
 
 HVA ST MEDIA DRIVER
 M:	Jean-Christophe Trotin <jean-christophe.trotin@st.com>
-- 
2.13.6
