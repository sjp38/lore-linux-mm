From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/2] Report the pagesize backing VMAs in /proc
Date: Mon, 22 Sep 2008 02:38:10 +0100
Message-Id: <1222047492-27622-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: LKML <linux-kernel@vger.kernel.org>
Cc: Linux-MM <linux-mm@kvack.org>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The following two patches add support for printing the size used for
hugepage-backed regions. This can be used by a user to verify that a
hugepage-aware application is using the expected page sizes.

The first patch should not be considered too contensious as it is highly
unlikely to break any parsers. There is a possibility that the second patch
will break parsers that arguably are already broken. More details are in
the patches themselves.

 fs/proc/task_mmu.c      |   29 +++++++++++++++++++++--------
 include/linux/hugetlb.h |   13 +++++++++++++
 2 files changed, 34 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
