Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx177.postini.com [74.125.245.177])
	by kanga.kvack.org (Postfix) with SMTP id 1527C6B0037
	for <linux-mm@kvack.org>; Tue, 28 May 2013 15:53:57 -0400 (EDT)
From: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Subject: [PATCH 0/2] hugetlbfs: support split page table lock
Date: Tue, 28 May 2013 15:52:49 -0400
Message-Id: <1369770771-8447-1-git-send-email-n-horiguchi@ah.jp.nec.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Andi Kleen <andi@firstfloor.org>, Michal Hocko <mhocko@suse.cz>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org

Hi,

In previous discussion [1] on "extend hugepage migration" patches, Michal and
Kosaki-san commented that in the patch "migrate: add migrate_entry_wait_huge()"
we need to solve the issue in the arch-independent manner and had better care
USE_SPLIT_PTLOCK=y case. So this patch(es) does that.

I made sure that the patched kernel shows no regression in functional tests
of libhugetlbfs.

[1]: http://thread.gmane.org/gmane.linux.kernel.mm/96665/focus=96661

Thanks,
Naoya Horiguchi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
