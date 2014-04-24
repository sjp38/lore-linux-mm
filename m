Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 067966B0035
	for <linux-mm@kvack.org>; Thu, 24 Apr 2014 16:49:48 -0400 (EDT)
Received: by mail-pd0-f171.google.com with SMTP id r10so2311148pdi.16
        for <linux-mm@kvack.org>; Thu, 24 Apr 2014 13:49:48 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [143.182.124.21])
        by mx.google.com with ESMTP id ci3si3375103pad.4.2014.04.24.13.49.47
        for <linux-mm@kvack.org>;
        Thu, 24 Apr 2014 13:49:48 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCHv2 0/5] get_user_pages() cleanup
Date: Thu, 24 Apr 2014 23:45:13 +0300
Message-Id: <1398372318-26612-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi Andrew,

Here's my attempt to cleanup of get_user_pages() code in order to make it
more maintainable.

v2:
 - rebased to current Linus' tree (1b17844b29ae);
 - add missing includes;
 - s/BUILD_BUG/BUG/;

Kirill A. Shutemov (5):
  mm: move get_user_pages()-related code to separate file
  mm: extract in_gate_area() case from __get_user_pages()
  mm: cleanup follow_page_mask()
  mm: extract code to fault in a page from __get_user_pages()
  mm: cleanup __get_user_pages()

 mm/Makefile   |   2 +-
 mm/gup.c      | 666 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/internal.h |   5 +
 mm/memory.c   | 645 --------------------------------------------------------
 4 files changed, 672 insertions(+), 646 deletions(-)
 create mode 100644 mm/gup.c

-- 
1.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
