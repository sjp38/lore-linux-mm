Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 100C46B0359
	for <linux-mm@kvack.org>; Tue, 20 Dec 2016 17:23:17 -0500 (EST)
Received: by mail-pg0-f69.google.com with SMTP id q10so517449577pgq.7
        for <linux-mm@kvack.org>; Tue, 20 Dec 2016 14:23:17 -0800 (PST)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id l24si23948313pgn.71.2016.12.20.14.23.16
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 20 Dec 2016 14:23:16 -0800 (PST)
From: Ross Zwisler <ross.zwisler@linux.intel.com>
Subject: [PATCH 0/2] Write protect DAX PMDs in *sync path
Date: Tue, 20 Dec 2016 15:23:04 -0700
Message-Id: <1482272586-21177-1-git-send-email-ross.zwisler@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Ross Zwisler <ross.zwisler@linux.intel.com>, Alexander Viro <viro@zeniv.linux.org.uk>, Andrew Morton <akpm@linux-foundation.org>, Christoph Hellwig <hch@lst.de>, Dan Williams <dan.j.williams@intel.com>, Dave Chinner <david@fromorbit.com>, Dave Hansen <dave.hansen@intel.com>, Jan Kara <jack@suse.cz>, Matthew Wilcox <mawilcox@microsoft.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-nvdimm@lists.01.org

Currently dax_mapping_entry_mkclean() fails to clean and write protect the
pmd_t of a DAX PMD entry during an *sync operation.  This can result in
data loss, as detailed in patch 2.

This series is based on Dan's "libnvdimm-pending" branch, which is the
current home for Jan's "dax: Page invalidation fixes" series.  You can find
a working tree here:

https://git.kernel.org/cgit/linux/kernel/git/zwisler/linux.git/log/?h=dax_pmd_clean

Ross Zwisler (2):
  mm: add follow_pte_pmd()
  dax: wrprotect pmd_t in dax_mapping_entry_mkclean

 fs/dax.c           | 51 ++++++++++++++++++++++++++++++++++++---------------
 include/linux/mm.h |  4 ++--
 mm/memory.c        | 41 ++++++++++++++++++++++++++++++++---------
 3 files changed, 70 insertions(+), 26 deletions(-)

-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
