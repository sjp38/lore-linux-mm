Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id 5B3406B0003
	for <linux-mm@kvack.org>; Sat, 14 Apr 2018 00:31:52 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id p189so5914394pfp.1
        for <linux-mm@kvack.org>; Fri, 13 Apr 2018 21:31:52 -0700 (PDT)
Received: from bombadil.infradead.org (bombadil.infradead.org. [2607:7c80:54:e::133])
        by mx.google.com with ESMTPS id a35-v6si7238509pli.71.2018.04.13.21.31.50
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-CHACHA20-POLY1305 bits=256/256);
        Fri, 13 Apr 2018 21:31:51 -0700 (PDT)
From: Matthew Wilcox <willy@infradead.org>
Subject: [PATCH 0/8] Various PageFlags cleanups
Date: Fri, 13 Apr 2018 21:31:37 -0700
Message-Id: <20180414043145.3953-1-willy@infradead.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Matthew Wilcox <mawilcox@microsoft.com>, "Kirill A . Shutemov" <kirill.shutemov@linux.intel.com>, Pavel Tatashin <pasha.tatashin@oracle.com>

From: Matthew Wilcox <mawilcox@microsoft.com>

I was trying to understand how it was safe to test PageLocked on a tail
page and started looking at how the pageflag policies were implemented.
I found three actual bugs (patches 5, 7 & 8), improved the documentation
and renamed a pile of things to be more readily explainable.

Matthew Wilcox (8):
  mm: Rename PF argument to modify
  mm: Rename PF_NO_TAIL to PF_TAIL_READ
  mm: Turn PF_POISONED_CHECK into CheckPageInit
  mm: Improve page flag policy documentation
  mm: Fix bug in page flags checking
  mm: Turn page policies into functions
  mm: Always check PagePolicyNoCompound
  mm: Optimise PagePolicyTailRead

 include/linux/mm.h         |   2 +-
 include/linux/page-flags.h | 107 ++++++++++++++++++++++++++-------------------
 2 files changed, 62 insertions(+), 47 deletions(-)

-- 
2.16.3
