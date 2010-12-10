Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id CF21D6B008C
	for <linux-mm@kvack.org>; Thu,  9 Dec 2010 21:49:40 -0500 (EST)
From: Ying Han <yinghan@google.com>
Subject: [PATCH 0/2] Add per cpuset meminfo
Date: Thu,  9 Dec 2010 18:49:03 -0800
Message-Id: <1291949345-13892-1-git-send-email-yinghan@google.com>
Sender: owner-linux-mm@kvack.org
To: Paul Menage <menage@google.com>, Andi Kleen <ak@linux.intel.com>, Mel Gorman <mel@csn.ul.ie>, Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>, Fengguang Wu <fengguang.wu@intel.com>, Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Export per cpuset meminfo through cpuset.meminfo file. This is easier than
user program to aggregate it across each nodes in nodemask.

Ying Han (2):
  Add hugetlb_report_nodemask_meminfo()
  Add per cpuset meminfo

 include/linux/hugetlb.h |    3 +
 kernel/cpuset.c         |  118 +++++++++++++++++++++++++++++++++++++++++++++++
 mm/hugetlb.c            |   21 ++++++++
 3 files changed, 142 insertions(+), 0 deletions(-)

-- 
1.7.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
