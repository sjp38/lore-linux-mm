Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id E02066B006C
	for <linux-mm@kvack.org>; Wed,  1 Apr 2015 21:52:11 -0400 (EDT)
Received: by pddn5 with SMTP id n5so73243801pdd.2
        for <linux-mm@kvack.org>; Wed, 01 Apr 2015 18:52:11 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id z7si5256002pas.78.2015.04.01.18.52.10
        for <linux-mm@kvack.org>;
        Wed, 01 Apr 2015 18:52:10 -0700 (PDT)
Date: Thu, 2 Apr 2015 09:51:14 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [mmotm:master 223/507] mm/hugetlb.c:940:6: sparse: symbol
 'set_page_huge_active' was not declared. Should it be static?
Message-ID: <201504020952.5zwySb4V%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: kbuild-all@01.org, Linux Memory Management List <linux-mm@kvack.org>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Johannes Weiner <hannes@cmpxchg.org>, Davidlohr Bueso <dave@stgolabs.net>, David Rientjes <rientjes@google.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Luiz Capitulino <lcapitulino@redhat.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Mike Kravetz <mike.kravetz@oracle.com>

tree:   git://git.cmpxchg.org/linux-mmotm.git master
head:   c226e49f30453de9c6d82b001a985254990b32e0
commit: 31e0965ee7e744862ba5d82b0e4d1dc04c947bd8 [223/507] mm-hugetlb-introduce-pagehugeactive-flag-fix
reproduce:
  # apt-get install sparse
  git checkout 31e0965ee7e744862ba5d82b0e4d1dc04c947bd8
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

   mm/hugetlb.c:933:6: sparse: symbol 'page_huge_active' was not declared. Should it be static?
>> mm/hugetlb.c:940:6: sparse: symbol 'set_page_huge_active' was not declared. Should it be static?
>> mm/hugetlb.c:946:6: sparse: symbol 'clear_page_huge_active' was not declared. Should it be static?
   mm/hugetlb.c:2071:20: sparse: symbol 'node_hstates' was not declared. Should it be static?
   mm/hugetlb.c:1327:20: sparse: context imbalance in 'gather_surplus_pages' - unexpected unlock
   mm/hugetlb.c:2950:9: sparse: context imbalance in 'hugetlb_cow' - unexpected unlock
   mm/hugetlb.c:3442:25: sparse: context imbalance in 'follow_hugetlb_page' - different lock contexts for basic block

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
