From: Mel Gorman <mel@csn.ul.ie>
Subject: [PATCH 0/3] Report the size of pages backing VMAs in /proc V2
Date: Tue, 23 Sep 2008 21:45:33 +0100
Message-Id: <1222202736-13311-1-git-send-email-mel@csn.ul.ie>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux-MM <linux-mm@kvack.org>
Cc: LKML <linux-kernel@vger.kernel.org>, Dave Hansen <dave@linux.vnet.ibm.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Mel Gorman <mel@csn.ul.ie>
List-ID: <linux-mm.kvack.org>

The following three patches add support for printing the size of pages to
back VMAs in maps and smaps. This can be used by a user to verify that a
hugepage-aware application is using the expected page sizes.

The first patch prints the size of page used by the kernel when allocating
pages for a VMA in /proc/pid/smaps and should not be considered too contentious
as it is highly unlikely to break any parsers. The second patch reports on
the size of page used by the MMU as it can differ - for example on POWER
using 64K as a base pagesize on older processors. The final patch reports
the size of page used by hugetlbfs regions in /proc/pid/maps. There is a
possibility that the final patch will break parsers but they are arguably
already broken. More details are in the patches themselves.

Changelog since V1
  o Fix build failure on !CONFIG_HUGETLB_PAGE
  o Uninline helper functions
  o Distinguish between base pagesize and MMU pagesize

 arch/powerpc/include/asm/hugetlb.h |    6 ++++++
 arch/powerpc/mm/hugetlbpage.c      |    7 +++++++
 fs/proc/task_mmu.c                 |   32 ++++++++++++++++++++++++--------
 include/linux/hugetlb.h            |    6 ++++++
 mm/hugetlb.c                       |   30 ++++++++++++++++++++++++++++++
 5 files changed, 73 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
