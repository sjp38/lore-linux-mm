Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f70.google.com (mail-pg0-f70.google.com [74.125.83.70])
	by kanga.kvack.org (Postfix) with ESMTP id 86F7B6B0292
	for <linux-mm@kvack.org>; Sat, 10 Jun 2017 17:55:55 -0400 (EDT)
Received: by mail-pg0-f70.google.com with SMTP id e1so39206926pga.5
        for <linux-mm@kvack.org>; Sat, 10 Jun 2017 14:55:55 -0700 (PDT)
Received: from mga07.intel.com (mga07.intel.com. [134.134.136.100])
        by mx.google.com with ESMTPS id i127si3831169pfb.96.2017.06.10.14.55.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 10 Jun 2017 14:55:54 -0700 (PDT)
Subject: [PATCH 0/2] mm: force enable thp for dax
From: Dan Williams <dan.j.williams@intel.com>
Date: Sat, 10 Jun 2017 14:49:26 -0700
Message-ID: <149713136649.17377.3742583729924020371.stgit@dwillia2-desk3.amr.corp.intel.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: Jan Kara <jack@suse.cz>, linux-nvdimm@lists.01.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Ross Zwisler <ross.zwisler@linux.intel.com>, hch@lst.de, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

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
 include/linux/huge_mm.h |   40 +++++++++++++++++++++++++++++-----------
 3 files changed, 35 insertions(+), 16 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
