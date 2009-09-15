Return-Path: <owner-linux-mm@kvack.org>
Received: from mail203.messagelabs.com (mail203.messagelabs.com [216.82.254.243])
	by kanga.kvack.org (Postfix) with SMTP id D5A686B004F
	for <linux-mm@kvack.org>; Tue, 15 Sep 2009 16:30:55 -0400 (EDT)
Date: Tue, 15 Sep 2009 21:30:09 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/4] mm: mlock, hugetlb, zero followups
In-Reply-To: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
Message-ID: <Pine.LNX.4.64.0909152127240.22199@sister.anvils>
References: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, Mel Gorman <mel@csn.ul.ie>, Minchan Kim <minchan.kim@gmail.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a gang of four patches against current mmotm, following
on from the eight around get_user_pages flags, addressing
concerns raised on those.  Best slotted in as a group after
mm-foll-flags-for-gup-flags.patch

 arch/mips/include/asm/pgtable.h |   14 ++++++++
 mm/hugetlb.c                    |   16 ++++++---
 mm/internal.h                   |    3 +
 mm/memory.c                     |   37 +++++++++++++++-------
 mm/mlock.c                      |   49 ++++++++++++++++++++++--------
 mm/page_alloc.c                 |    1 
 6 files changed, 89 insertions(+), 31 deletions(-)

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
