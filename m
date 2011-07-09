Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 509596B007E
	for <linux-mm@kvack.org>; Sat,  9 Jul 2011 15:41:47 -0400 (EDT)
Received: by pwi12 with SMTP id 12so2263896pwi.14
        for <linux-mm@kvack.org>; Sat, 09 Jul 2011 12:41:43 -0700 (PDT)
From: Raghavendra D Prabhu <raghu.prabhu13@gmail.com>
Subject: [PATCH 0/3] Readahead fixes
Date: Sun, 10 Jul 2011 01:11:17 +0530
Message-Id: <cover.1310239575.git.rprabhu@wnohang.net>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: fengguang.wu@intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, Raghavendra D Prabhu <rprabhu@wnohang.net>

Minor readahead fixes, details in respective patch mails

Raghavendra D Prabhu (3):
  Change the check for PageReadahead into an else-if
  Remove file_ra_state from arguments of count_history_pages.
  Move the check for ra_pages after VM_SequentialReadHint()

 mm/filemap.c   |    8 ++++----
 mm/readahead.c |    3 +--
 2 files changed, 5 insertions(+), 6 deletions(-)

-- 
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
