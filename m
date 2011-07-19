Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id 50AC56B00F6
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 18:51:34 -0400 (EDT)
Received: from kpbe19.cbf.corp.google.com (kpbe19.cbf.corp.google.com [172.25.105.83])
	by smtp-out.google.com with ESMTP id p6JMpWMT025670
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:51:32 -0700
Received: from iwn9 (iwn9.prod.google.com [10.241.68.73])
	by kpbe19.cbf.corp.google.com with ESMTP id p6JMpUh8027801
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:51:30 -0700
Received: by iwn9 with SMTP id 9so6813413iwn.39
        for <linux-mm@kvack.org>; Tue, 19 Jul 2011 15:51:30 -0700 (PDT)
Date: Tue, 19 Jul 2011 15:51:12 -0700 (PDT)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/3] mm: tmpfs radix_tree swap leftovers
Message-ID: <alpine.LSU.2.00.1107191549540.1593@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's three miscellaneous patches on top of the tmpfs radix_tree swap
work in 3.0-rc6-mm1: an overdue unrelated cleanup in radix_tree_tag_get(),
an unfortunately necessary speedup to tmpfs swapoff, and an attempt to
address your review feedback on the exceptional cases in filemap.c.

1/3 radix_tree: clean away saw_unset_tag leftovers
2/3 tmpfs radix_tree: locate_item to speed up swapoff
3/3 mm: clarify the radix_tree exceptional cases

 include/linux/radix-tree.h |    1 
 lib/radix-tree.c           |  102 ++++++++++++++++++++++++++++++++---
 mm/filemap.c               |   66 +++++++++++++++-------
 mm/mincore.c               |    1 
 mm/shmem.c                 |   50 +++--------------
 5 files changed, 149 insertions(+), 71 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
