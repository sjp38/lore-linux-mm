Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f52.google.com (mail-pa0-f52.google.com [209.85.220.52])
	by kanga.kvack.org (Postfix) with ESMTP id 7555A6B0038
	for <linux-mm@kvack.org>; Wed, 21 Oct 2015 10:09:55 -0400 (EDT)
Received: by padhk11 with SMTP id hk11so56151998pad.1
        for <linux-mm@kvack.org>; Wed, 21 Oct 2015 07:09:55 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id qo8si13603894pac.117.2015.10.21.07.09.54
        for <linux-mm@kvack.org>;
        Wed, 21 Oct 2015 07:09:54 -0700 (PDT)
Date: Wed, 21 Oct 2015 20:58:56 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [linux-review:Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
 9356/9695] mm/hugetlb.c:1583:13: sparse: symbol
 '__alloc_buddy_huge_page_no_mpol' was not declared. Should it be static?
Message-ID: <201510212038.HxPwijWe%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Hansen <dave.hansen@linux.intel.com>
Cc: kbuild-all@01.org, Andrew Morton <akpm@linux-foundation.org>, Linux Memory Management List <linux-mm@kvack.org>

Hi Dave,

[auto build test WARNING on v4.3-rc6-108-gce1fad2 -- if it's inappropriate base, please suggest rules for selecting the more suitable base]

url:    https://github.com/0day-ci/linux/commits/Tetsuo-Handa/mm-vmscan-Use-accurate-values-for-zone_reclaimable-checks/20151021-203036
reproduce:
        # apt-get install sparse
        make ARCH=x86_64 allmodconfig
        make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/hugetlb.c:1583:13: sparse: symbol '__alloc_buddy_huge_page_no_mpol' was not declared. Should it be static?
>> mm/hugetlb.c:1593:13: sparse: symbol '__alloc_buddy_huge_page_with_mpol' was not declared. Should it be static?
   mm/hugetlb.c:1642:20: sparse: context imbalance in 'gather_surplus_pages' - unexpected unlock
   mm/hugetlb.c:3361:9: sparse: context imbalance in 'hugetlb_cow' - unexpected unlock
   mm/hugetlb.c:3905:25: sparse: context imbalance in 'follow_hugetlb_page' - different lock contexts for basic block

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
