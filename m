Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ea0-f172.google.com (mail-ea0-f172.google.com [209.85.215.172])
	by kanga.kvack.org (Postfix) with ESMTP id 1D34D6B0037
	for <linux-mm@kvack.org>; Mon, 10 Feb 2014 12:28:09 -0500 (EST)
Received: by mail-ea0-f172.google.com with SMTP id l9so2657184eaj.17
        for <linux-mm@kvack.org>; Mon, 10 Feb 2014 09:28:08 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id d8si27328443eeh.221.2014.02.10.09.28.06
        for <linux-mm@kvack.org>;
        Mon, 10 Feb 2014 09:28:07 -0800 (PST)
From: Luiz Capitulino <lcapitulino@redhat.com>
Subject: [PATCH 0/4] hugetlb: add hugepagesnid= command-line option
Date: Mon, 10 Feb 2014 12:27:44 -0500
Message-Id: <1392053268-29239-1-git-send-email-lcapitulino@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, akpm@linux-foundation.org, mtosatti@redhat.com, mgorman@suse.de, aarcange@redhat.com, andi@firstfloor.org, riel@redhat.com

HugeTLB command-line option hugepages= allows the user to specify how many
huge pages should be allocated at boot. On NUMA systems, this argument
automatically distributes huge pages allocation among nodes, which can
be undesirable.

The hugepagesnid= option introduced by this commit allows the user
to specify which NUMA nodes should be used to allocate boot-time HugeTLB
pages. For example, hugepagesnid=0,2,2G will allocate two 2G huge pages
from node 0 only. More details on patch 3/4 and patch 4/4.

Luiz capitulino (4):
  memblock: memblock_virt_alloc_internal(): alloc from specified node
    only
  memblock: add memblock_virt_alloc_nid_nopanic()
  hugetlb: add hugepagesnid= command-line option
  hugetlb: hugepagesnid=: add 1G huge page support

 Documentation/kernel-parameters.txt |   8 +++
 arch/x86/mm/hugetlbpage.c           |  35 ++++++++++++
 include/linux/bootmem.h             |   4 ++
 include/linux/hugetlb.h             |   2 +
 mm/hugetlb.c                        | 103 ++++++++++++++++++++++++++++++++++++
 mm/memblock.c                       |  41 ++++++++++++--
 6 files changed, 190 insertions(+), 3 deletions(-)

-- 
1.8.1.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
