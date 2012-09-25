Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx184.postini.com [74.125.245.184])
	by kanga.kvack.org (Postfix) with SMTP id 4562B6B0062
	for <linux-mm@kvack.org>; Tue, 25 Sep 2012 14:11:25 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] thp: avoid VM_BUG_ON page_count(page) false positives in __collapse_huge_page_copy
Date: Tue, 25 Sep 2012 20:11:17 +0200
Message-Id: <1348596678-2768-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, Rik van Riel <riel@redhat.com>, Johannes Weiner <jweiner@redhat.com>, Hugh Dickins <hughd@google.com>, Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>

Some time ago Petr once reproduced a false positive VM_BUG_ON in
khugepaged while running the autonuma-benchmark on a large 8 node
system. All production kernels out there have DEBUG_VM=n so it was
only noticeable on self built kernels. It's not easily reproducible
even on the 8 nodes system.

This patch removes the false positive and it has been tested for a
while and it's good idea to queue it for upstream too. It's not urgent
and probably not worth it for -stable, though it wouldn't hurt. On
smaller systems it's not reproducible AFIK.

Andrea Arcangeli (1):
  thp: avoid VM_BUG_ON page_count(page) false positives in
    __collapse_huge_page_copy

 mm/huge_memory.c |   19 ++++++++++++++++++-
 1 files changed, 18 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
