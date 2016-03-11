Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f175.google.com (mail-pf0-f175.google.com [209.85.192.175])
	by kanga.kvack.org (Postfix) with ESMTP id 2B090828DF
	for <linux-mm@kvack.org>; Fri, 11 Mar 2016 16:13:11 -0500 (EST)
Received: by mail-pf0-f175.google.com with SMTP id 129so92022073pfw.1
        for <linux-mm@kvack.org>; Fri, 11 Mar 2016 13:13:11 -0800 (PST)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id c17si16190465pfd.70.2016.03.11.13.13.07
        for <linux-mm@kvack.org>;
        Fri, 11 Mar 2016 13:13:07 -0800 (PST)
From: Matthew Wilcox <matthew.r.wilcox@intel.com>
Subject: [PATCH 0/3] Make pfn_t suitable for placing in the radix tree
Date: Fri, 11 Mar 2016 16:13:01 -0500
Message-Id: <1457730784-9890-1-git-send-email-matthew.r.wilcox@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Williams <dan.j.williams@intel.com>
Cc: Matthew Wilcox <matthew.r.wilcox@intel.com>, linux-nvdimm@lists.01.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, willy@linux.intel.com

I did some experimenting with converting the DAX radix tree from storing
sector numbers to storing pfn_t.  While we're not ready to do that
conversion yet, these pieces make sense to at least get reviewed now,
and maybe get upstream.

I think the first patch is worthwhile all by itself as a stepping stone to
making SG lists contain PFNs instead of pages.

Matthew Wilcox (3):
  pfn_t: Change the encoding
  pfn_t: Support for huge PFNs
  pfn_t: New functions pfn_t_add and pfn_t_cmp

 include/linux/pfn_t.h | 72 +++++++++++++++++++++++++++++++++++++++++++--------
 1 file changed, 61 insertions(+), 11 deletions(-)

-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
