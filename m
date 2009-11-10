Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 618F46B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 16:50:13 -0500 (EST)
Date: Tue, 10 Nov 2009 21:50:06 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/6] mm: prepare for ksm swapping
Message-ID: <Pine.LNX.4.64.0911102142570.2272@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a series of six miscellaneous mm patches against 2.6.32-rc5-mm1,
intended to follow my earlier swap_info patches, or slot in just before
mmend in the mmotm series.

Apart from the sixth, they have some relevance to the KSM-page swapping
patches, following after a few days.  They clear away some mm cruft,
to let that series concentrate on ksm.c; but should stand on their own.

 include/linux/ksm.h        |    5 -
 include/linux/mm.h         |   17 +++
 include/linux/page-flags.h |    8 -
 include/linux/rmap.h       |    8 +
 mm/Kconfig                 |   14 --
 mm/internal.h              |   26 ++---
 mm/memory-failure.c        |    2 
 mm/memory.c                |    4 
 mm/migrate.c               |   11 --
 mm/mlock.c                 |    2 
 mm/page_alloc.c            |    4 
 mm/rmap.c                  |  174 +++++++++++------------------------
 mm/swapfile.c              |    2 
 13 files changed, 110 insertions(+), 167 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
