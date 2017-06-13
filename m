Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id EE9B56B0279
	for <linux-mm@kvack.org>; Tue, 13 Jun 2017 19:14:49 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id o74so87990498pfi.6
        for <linux-mm@kvack.org>; Tue, 13 Jun 2017 16:14:49 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id s14si892005pfj.100.2017.06.13.16.14.48
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 13 Jun 2017 16:14:48 -0700 (PDT)
Subject: [PATCH v2 0/2] mm: force enable thp for dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Tue, 13 Jun 2017 16:08:20 -0700
Message-ID: <149739530052.20686.9000645746376519779.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Changes since v1 [1]:
1/ Fix the transparent_hugepage_enabled() rewrite to be functionally
   equivalent to the old state (Ross)

2/ Add a note as to why we are including fs.h in huge_mm.h so that we
   remember to clean this up if vma_is_dax() is ever moved, or we add a
   VM_* flag for this case. (prompted by Kirill's feedback).

3/ Add some ack and review tags.

[1]: https://www.spinics.net/lists/linux-mm/msg128852.html

---

Hi Andrew,

Please consider taking these 2 patches for 4.13. I spent some time
debugging why a user's device-dax configuration was always failing and
it turned out that their thp policy was set to 'never'. DAX should be
exempt from the policy since it is statically allocated and does not
suffer from any of the potentially negative side effects of thp. More
details in patch 2.

---

Dan Williams (2):
      mm: improve readability of transparent_hugepage_enabled()
      mm: always enable thp for dax mappings


 include/linux/dax.h     |    5 -----
 include/linux/fs.h      |    6 ++++++
 include/linux/huge_mm.h |   37 ++++++++++++++++++++++++++-----------
 3 files changed, 32 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
