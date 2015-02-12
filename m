Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f169.google.com (mail-pd0-f169.google.com [209.85.192.169])
	by kanga.kvack.org (Postfix) with ESMTP id C9FE56B0038
	for <linux-mm@kvack.org>; Thu, 12 Feb 2015 03:54:42 -0500 (EST)
Received: by pdbnh10 with SMTP id nh10so6365830pdb.11
        for <linux-mm@kvack.org>; Thu, 12 Feb 2015 00:54:42 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id r2si4174673pds.131.2015.02.12.00.54.41
        for <linux-mm@kvack.org>;
        Thu, 12 Feb 2015 00:54:42 -0800 (PST)
Date: Thu, 12 Feb 2015 16:54:04 +0800
From: kbuild test robot <fengguang.wu@intel.com>
Subject: [aa:userfault 17/19] mm/userfaultfd.c:48:6: sparse: symbol
 'double_down_read' was not declared. Should it be static?
Message-ID: <201502121644.mekdzvbV%fengguang.wu@intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrea Arcangeli <aarcange@redhat.com>
Cc: kbuild-all@01.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/andrea/aa.git userfault
head:   9866337e3999d167b77303ad9e57fd20919893e3
commit: e2ccdb8c9f49438f9c8910f2f93c7e5ee35d8644 [17/19] userfaultfd: add new syscall to provide memory externalization
reproduce:
  # apt-get install sparse
  git checkout e2ccdb8c9f49438f9c8910f2f93c7e5ee35d8644
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> mm/userfaultfd.c:48:6: sparse: symbol 'double_down_read' was not declared. Should it be static?
>> mm/userfaultfd.c:67:6: sparse: symbol 'double_up_read' was not declared. Should it be static?
>> mm/userfaultfd.c:34:9: sparse: context imbalance in 'double_pt_lock' - different lock contexts for basic block
>> mm/userfaultfd.c:44:9: sparse: context imbalance in 'double_pt_unlock' - different lock contexts for basic block
>> mm/userfaultfd.c:63:9: sparse: context imbalance in 'double_down_read' - wrong count at exit
>> mm/userfaultfd.c:73:9: sparse: context imbalance in 'double_up_read' - wrong count at exit
>> mm/userfaultfd.c:551:9: sparse: context imbalance in 'remap_anon_pages' - different lock contexts for basic block

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
