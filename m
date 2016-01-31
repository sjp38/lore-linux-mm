Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id C93D4828DF
	for <linux-mm@kvack.org>; Sun, 31 Jan 2016 07:19:58 -0500 (EST)
Received: by mail-pa0-f50.google.com with SMTP id uo6so67490960pac.1
        for <linux-mm@kvack.org>; Sun, 31 Jan 2016 04:19:58 -0800 (PST)
Received: from mga01.intel.com (mga01.intel.com. [192.55.52.88])
        by mx.google.com with ESMTP id sb2si16574417pac.161.2016.01.31.04.19.58
        for <linux-mm@kvack.org>;
        Sun, 31 Jan 2016 04:19:58 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/6] DAX cleanups
Date: Sun, 31 Jan 2016 23:19:49 +1100
Message-Id: <1454242795-18038-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-mm@kvack.org, linux-nvdimm@lists.01.org, linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org, willy@linux.intel.com

Very little exciting in here.  This is all based on the PUD support code
that I just sent, mostly addressing things that came up during review
of the PUD code but weren't really justifiable as being mixed into the
adding of PUD support.

Matthew Wilcox (6):
  dax: Use vmf->gfp_mask
  dax: Remove unnecessary rechecking of i_size
  dax: Use vmf->pgoff in fault handlers
  dax: Use PAGE_CACHE_SIZE where appropriate
  dax: Factor dax_insert_pmd_mapping out of dax_pmd_fault
  dax: Factor dax_insert_pud_mapping out of dax_pud_fault

 fs/dax.c | 395 ++++++++++++++++++++++++++-------------------------------------
 1 file changed, 164 insertions(+), 231 deletions(-)

-- 
2.7.0.rc3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
