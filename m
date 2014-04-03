Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f42.google.com (mail-pa0-f42.google.com [209.85.220.42])
	by kanga.kvack.org (Postfix) with ESMTP id 8BD6B6B0031
	for <linux-mm@kvack.org>; Thu,  3 Apr 2014 10:37:56 -0400 (EDT)
Received: by mail-pa0-f42.google.com with SMTP id fb1so1955163pad.15
        for <linux-mm@kvack.org>; Thu, 03 Apr 2014 07:37:56 -0700 (PDT)
Received: from mga11.intel.com (mga11.intel.com. [192.55.52.93])
        by mx.google.com with ESMTP id xs1si3176198pab.401.2014.04.03.07.37.55
        for <linux-mm@kvack.org>;
        Thu, 03 Apr 2014 07:37:55 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/5] get_user_pages() cleanup
Date: Thu,  3 Apr 2014 17:35:17 +0300
Message-Id: <1396535722-31108-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Jan Kara <jack@suse.cz>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Hi,

Here's my attempt to cleanup of get_user_pages() code in order to make it
more maintainable.

Tested on my laptop for few hours. No crashes so far ;)

Let me know if it makes sense. Any suggestions are welcome.

Kirill A. Shutemov (5):
  mm: move get_user_pages()-related code to separate file
  mm: extract in_gate_area() case from __get_user_pages()
  mm: cleanup follow_page_mask()
  mm: extract code to fault in a page from __get_user_pages()
  mm: cleanup __get_user_pages()

 mm/Makefile |   2 +-
 mm/gup.c    | 638 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 mm/memory.c | 611 ---------------------------------------------------------
 3 files changed, 639 insertions(+), 612 deletions(-)
 create mode 100644 mm/gup.c

-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
