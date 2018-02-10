Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 03BC16B027C
	for <linux-mm@kvack.org>; Fri,  9 Feb 2018 19:38:24 -0500 (EST)
Received: by mail-pg0-f70.google.com with SMTP id q13so4868823pgt.17
        for <linux-mm@kvack.org>; Fri, 09 Feb 2018 16:38:23 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTPS id s1si523830pgp.577.2018.02.09.16.38.22
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 09 Feb 2018 16:38:22 -0800 (PST)
Subject: [PATCH v2 0/2] mm, smaps: MMUPageSize for device-dax
From: Dave Jiang <dave.jiang@intel.com>
Date: Fri, 09 Feb 2018 17:38:21 -0700
Message-ID: <151822289999.52376.4998780583577188804.stgit@djiang5-desk3.ch.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, dan.j.williams@intel.com, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, mhocko@kernel.org

Andrew,

>From Dan Williams:
Here is another occasion where we want special-case hugetlbfs enabling
to also apply to device-dax. I started to wonder what other hstate
conversions we might do beyond ->split() and ->pagesize(), but this
appears to be the last of the usages of hstate_vma() in
generic/non-hugetlbfs specific code paths.

v2:
I fixed up the powerpc build issue that Michal reported by restoring the
original location of the function and making the symbol weak.

---

Dan Williams (2):
      mm, hugetlbfs: introduce ->pagesize() to vm_operations_struct
      device-dax: implement ->pagesize() for smaps to report MMUPageSize


 arch/powerpc/mm/hugetlbpage.c |    5 +----
 drivers/dax/device.c          |   10 ++++++++++
 include/linux/mm.h            |    1 +
 mm/hugetlb.c                  |   23 ++++++++++++-----------
 4 files changed, 24 insertions(+), 15 deletions(-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
