Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ob0-f200.google.com (mail-ob0-f200.google.com [209.85.214.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5BB396B0289
	for <linux-mm@kvack.org>; Tue, 14 Jun 2016 04:42:44 -0400 (EDT)
Received: by mail-ob0-f200.google.com with SMTP id jt9so11654401obc.2
        for <linux-mm@kvack.org>; Tue, 14 Jun 2016 01:42:44 -0700 (PDT)
Received: from mga02.intel.com (mga02.intel.com. [134.134.136.20])
        by mx.google.com with ESMTP id w1si37499042pfa.213.2016.06.14.01.42.43
        for <linux-mm@kvack.org>;
        Tue, 14 Jun 2016 01:42:43 -0700 (PDT)
From: "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>
Subject: [PATCH 0/2] Reverts to address unixbench regression
Date: Tue, 14 Jun 2016 11:42:28 +0300
Message-Id: <1465893750-44080-1-git-send-email-kirill.shutemov@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>, Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Mel Gorman <mgorman@suse.de>, "Huang, Ying" <ying.huang@intel.com>, Michal Hocko <mhocko@suse.com>, Minchan Kim <minchan@kernel.org>, Vinayak Menon <vinmenon@codeaurora.org>, Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>

Faultaround changes cause regression in unixbench, let's revert them.

Kirill A. Shutemov (2):
  Revert "mm: make faultaround produce old ptes"
  Revert "mm: disable fault around on emulated access bit architecture"

 include/linux/mm.h |  2 +-
 mm/filemap.c       |  2 +-
 mm/memory.c        | 31 +++++--------------------------
 3 files changed, 7 insertions(+), 28 deletions(-)

-- 
2.8.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
