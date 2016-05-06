Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f200.google.com (mail-qk0-f200.google.com [209.85.220.200])
	by kanga.kvack.org (Postfix) with ESMTP id 5ED826B0253
	for <linux-mm@kvack.org>; Fri,  6 May 2016 11:04:05 -0400 (EDT)
Received: by mail-qk0-f200.google.com with SMTP id x7so278500854qkd.2
        for <linux-mm@kvack.org>; Fri, 06 May 2016 08:04:05 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id z109si9802680qgd.100.2016.05.06.08.04.03
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 06 May 2016 08:04:03 -0700 (PDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH 0/3] mm: thp: mapcount updates
Date: Fri,  6 May 2016 17:03:57 +0200
Message-Id: <1462547040-1737-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: Alex Williamson <alex.williamson@redhat.com>, "Kirill A. Shutemov" <kirill@shutemov.name>

Hello,

1/3 is a bugfix and it fixes userland (not kernel) data corruption
with vfio (and in general device driver) page pinning done with
get_user_pages. More testing of it under any load is welcome (also not
necessarily a page pinning load using vfio).

Along with the above I'm sending also 2/3 and 3/3 but those are not
meant to be merged upstream quickly and they're very low priority and
furthermore 2/3 is not zero risk and it didn't get enough testing
yet. Queuing 2/3 in -mm to give it more exposure should be ok
though. 2/3 is only suitable for merging at the very opening of merge
window anyway.

Andrea Arcangeli (3):
  mm: thp: calculate the mapcount correctly for THP pages during WP
    faults
  mm: thp: microoptimize compound_mapcount()
  mm: thp: split_huge_pmd_address() comment improvement

 include/linux/mm.h   | 12 +++++++--
 include/linux/swap.h |  8 +++---
 mm/huge_memory.c     | 73 ++++++++++++++++++++++++++++++++++++++++++++--------
 mm/memory.c          | 22 ++++++++++------
 mm/swapfile.c        | 13 +++++-----
 5 files changed, 98 insertions(+), 30 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
