Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx122.postini.com [74.125.245.122])
	by kanga.kvack.org (Postfix) with SMTP id 36EE26B0044
	for <linux-mm@kvack.org>; Sat, 22 Sep 2012 06:33:30 -0400 (EDT)
Received: by pbbro12 with SMTP id ro12so10081941pbb.14
        for <linux-mm@kvack.org>; Sat, 22 Sep 2012 03:33:29 -0700 (PDT)
From: raghu.prabhu13@gmail.com
Subject: [PATCH 0/5] Readahead fixes / improvements
Date: Sat, 22 Sep 2012 16:03:09 +0530
Message-Id: <cover.1348290849.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: fengguang.wu@intel.com, viro@zeniv.linux.org.uk, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

From: Raghavendra D Prabhu <rprabhu@wnohang.net>

Following are some of the fixes / improvements to the page cache readahead:
first four are minor fixes along the readahead path, the last one is an
improvement to use find_get_pages in __do_page_cache_readahead.

Raghavendra D Prabhu (5):
  mm/readahead: Check return value of read_pages
  mm/readahead: Change the condition for SetPageReadahead
  Remove file_ra_state from arguments of count_history_pages.
  Move the check for ra_pages after VM_SequentialReadHint()
  mm/readahead: Use find_get_pages instead of radix_tree_lookup.

 mm/filemap.c   |  5 +++--
 mm/readahead.c | 50 ++++++++++++++++++++++++++++++++++----------------
 2 files changed, 37 insertions(+), 18 deletions(-)

-- 
1.7.12.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
