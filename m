Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id 3CE9E6B0033
	for <linux-mm@kvack.org>; Thu,  7 Dec 2017 22:39:06 -0500 (EST)
Received: by mail-pg0-f71.google.com with SMTP id 200so6827090pge.12
        for <linux-mm@kvack.org>; Thu, 07 Dec 2017 19:39:06 -0800 (PST)
Received: from mga17.intel.com (mga17.intel.com. [192.55.52.151])
        by mx.google.com with ESMTPS id w11si5260695pfk.209.2017.12.07.19.39.04
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 07 Dec 2017 19:39:05 -0800 (PST)
Subject: [PATCH 0/2] mm, smaps: MMUPageSize for device-dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Thu, 07 Dec 2017 19:30:49 -0800
Message-ID: <151270384965.21215.2022156459463260344.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jane Chu <jane.chu@oracle.com>, linux-nvdimm@lists.01.org, Michael Ellerman <mpe@ellerman.id.au>, linux-mm@kvack.org, Paul Mackerras <paulus@samba.org>, Benjamin Herrenschmidt <benh@kernel.crashing.org>

Andrew,

Here is another occasion where we want special-case hugetlbfs enabling
to also apply to device-dax. I started to wonder what other hstate
conversions we might do beyond ->split() and ->pagesize(), but this
appears to be the last of the usages of hstate_vma() in
generic/non-hugetlbfs specific code paths.

This is 4.16 material.

---

Dan Williams (2):
      mm, hugetlbfs: introduce ->pagesize() to vm_operations_struct
      device-dax: implement ->pagesize() for smaps to report MMUPageSize


 arch/powerpc/mm/hugetlbpage.c |    5 +----
 drivers/dax/device.c          |   10 ++++++++++
 include/linux/hugetlb.h       |   30 ++++++++++++++++++++++++------
 include/linux/mm.h            |    1 +
 mm/hugetlb.c                  |   38 ++++++++------------------------------
 5 files changed, 44 insertions(+), 40 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
