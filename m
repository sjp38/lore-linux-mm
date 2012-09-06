Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx181.postini.com [74.125.245.181])
	by kanga.kvack.org (Postfix) with SMTP id 31A826B00B7
	for <linux-mm@kvack.org>; Thu,  6 Sep 2012 01:15:27 -0400 (EDT)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH v2 0/3] memory-hotplug: handle page race between allocation and isolation
Date: Thu,  6 Sep 2012 14:16:56 +0900
Message-Id: <1346908619-16056-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Mel Gorman <mgorman@suse.de>, Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>, Xishi Qiu <qiuxishi@huawei.com>, Wen Congyang <wency@cn.fujitsu.com>, Minchan Kim <minchan@kernel.org>

Memory hotplug has a subtle race problem so this patchset fixes the problem
(Look at [3/3] for detail and please confirm the problem before review
other patches in this series.)

 [1/3] is just clean up and help for [2/3].
 [2/3] keeps the migratetype information to freed page's index field
       and [3/3] uses the information.
 [3/3] fixes the race problem with [2/3]'s information.

After applying [2/3], migratetype argument in __free_one_page
and free_one_page is redundant so we can remove it but I decide
to not touch them because it increases code size about 50 byte.

Minchan Kim (3):
  use get_page_migratetype instead of page_private
  mm: remain migratetype in freed page
  memory-hotplug: bug fix race between isolation and allocation

 include/linux/mm.h  |   12 ++++++++++++
 mm/page_alloc.c     |   17 +++++++++++------
 mm/page_isolation.c |    7 +++++--
 3 files changed, 28 insertions(+), 8 deletions(-)

-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
