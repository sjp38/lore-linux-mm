Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 8D8836B0038
	for <linux-mm@kvack.org>; Tue,  6 Sep 2016 12:52:20 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id g202so375506612pfb.3
        for <linux-mm@kvack.org>; Tue, 06 Sep 2016 09:52:20 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTPS id x80si9309465pff.224.2016.09.06.09.52.19
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 06 Sep 2016 09:52:19 -0700 (PDT)
Subject: [PATCH 0/5] device-dax and huge-page dax fixes for 4.8-rc6
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 06 Sep 2016 09:49:20 -0700
Message-ID: <147318056046.30325.5100892122988191500.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-nvdimm@lists.01.org
Cc: Toshi Kani <toshi.kani@hpe.com>, Matthew Wilcox <mawilcox@microsoft.com>, Nilesh Choudhury <nilesh.choudhury@oracle.com>, linux-kernel@vger.kernel.org, stable@vger.kernel.org, linux-mm@kvack.org, akpm@linux-foundation.org, Ross Zwisler <ross.zwisler@linux.intel.com>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Kai Zhang <kai.ka.zhang@oracle.com>

Kai and Toshi reported poor performance with huge-page dax mappings and
while debugging a few more bugs were discovered in the device-dax driver
and mm.  The following fixes target 4.8-rc6 and are tagged for -stable:

- device-dax incorrectly translates the file offset to a physical
  resource address

- show_smap() crashes on huge-page dax mappings

- huge-page dax mappings are inadvertently being marked as
  _PAGE_CACHE_MODE_UC instead of _PAGE_CACHE_MODE_WB

I would like to take this set through nvdimm.git with acks from mm folks
as there is 4.9 device-dax development that depends on these changes.

---

Dan Williams (5):
      dax: fix mapping size check
      dax: fix offset to physical address translation
      mm: fix show_smap() for zone_device-pmd ranges
      mm: fix cache mode of dax pmd mappings
      mm: cleanup pfn_t usage in track_pfn_insert()


 arch/x86/mm/pat.c             |    4 ++--
 drivers/dax/dax.c             |   12 +++++++-----
 fs/proc/task_mmu.c            |    2 ++
 include/asm-generic/pgtable.h |    4 ++--
 mm/huge_memory.c              |    6 ++----
 mm/memory.c                   |    2 +-
 6 files changed, 16 insertions(+), 14 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
