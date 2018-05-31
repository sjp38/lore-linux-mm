Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f69.google.com (mail-pg0-f69.google.com [74.125.83.69])
	by kanga.kvack.org (Postfix) with ESMTP id 59E306B0005
	for <linux-mm@kvack.org>; Thu, 31 May 2018 09:55:03 -0400 (EDT)
Received: by mail-pg0-f69.google.com with SMTP id v133-v6so6336026pgb.10
        for <linux-mm@kvack.org>; Thu, 31 May 2018 06:55:03 -0700 (PDT)
Received: from mga05.intel.com (mga05.intel.com. [192.55.52.43])
        by mx.google.com with ESMTPS id r14-v6si37280089pfa.296.2018.05.31.06.55.02
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 31 May 2018 06:55:02 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] mm/page_ext: Trivial cleanups
Date: Thu, 31 May 2018 16:54:55 +0300
Message-Id: <20180531135457.20167-1-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

A pair of trivial cleanups in preparation for memory encryption.

Kirill A. Shutemov (2):
  mm/page_ext: Drop definition of unused PAGE_EXT_DEBUG_POISON
  mm/page_ext: Constify lookup_page_ext() argument

 include/linux/page_ext.h | 15 ++-------------
 mm/page_ext.c            |  4 ++--
 2 files changed, 4 insertions(+), 15 deletions(-)

-- 
2.17.0
