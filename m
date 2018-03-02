Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id F25616B0003
	for <linux-mm@kvack.org>; Thu,  1 Mar 2018 22:58:03 -0500 (EST)
Received: by mail-pf0-f197.google.com with SMTP id c83so4574165pfk.5
        for <linux-mm@kvack.org>; Thu, 01 Mar 2018 19:58:03 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l2si3422927pgs.276.2018.03.01.19.58.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 01 Mar 2018 19:58:02 -0800 (PST)
Subject: [PATCH v3 0/3] mm, smaps: MMUPageSize for device-dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 01 Mar 2018 19:48:56 -0800
Message-ID: <151996253609.27922.9983044853291257359.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Michael Ellerman <mpe@ellerman.id.au>, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Jane Chu <jane.chu@oracle.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Changes since v2:
* Split the fix of the definition vma_mmu_pagesize() on powerpc to its
  own patch.

[1]: https://lists.01.org/pipermail/linux-nvdimm/2018-February/014101.html

---

Andrew,

Similar to commit 31383c6865a5 "mm, hugetlbfs: introduce ->split() to
vm_operations_struct" here is another occasion where we want
special-case hugetlbfs/hstate enabling to also apply to device-dax.

This begs the question what other hstate conversions we might do beyond
->split() and ->pagesize(), but this appears to be the last of the
usages of hstate_vma() in generic/non-hugetlbfs specific code paths.

---

Dan Williams (3):
      mm, powerpc: use vma_kernel_pagesize() in vma_mmu_pagesize()
      mm, hugetlbfs: introduce ->pagesize() to vm_operations_struct
      device-dax: implement ->pagesize() for smaps to report MMUPageSize


 arch/powerpc/include/asm/hugetlb.h |    6 ------
 arch/powerpc/mm/hugetlbpage.c      |    5 +----
 drivers/dax/device.c               |   10 ++++++++++
 include/linux/mm.h                 |    1 +
 mm/hugetlb.c                       |   27 ++++++++++++++-------------
 5 files changed, 26 insertions(+), 23 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
