Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id 719956B0044
	for <linux-mm@kvack.org>; Fri, 23 Mar 2012 12:42:50 -0400 (EDT)
From: Andrea Arcangeli <aarcange@redhat.com>
Subject: [PATCH] pdm_trans_unstable problem
Date: Fri, 23 Mar 2012 17:42:43 +0100
Message-Id: <1332520964-30491-1-git-send-email-aarcange@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Andrew Morton <akpm@linux-foundation.org>, Mel Gorman <mgorman@suse.de>, Hugh Dickins <hughd@google.com>, Larry Woodman <lwoodman@redhat.com>, Ulrich Obergfell <uobergfe@redhat.com>, Rik van Riel <riel@redhat.com>, Mark Salter <msalter@redhat.com>

Hi,

While git rebasing I got rejects in certain locations. This would be
my remaining diff.

Andrea Arcangeli (1):
  mm: thp: fixup pmd_trans_unstable() locations

 fs/proc/task_mmu.c |    5 ++---
 mm/memcontrol.c    |    4 ++++
 2 files changed, 6 insertions(+), 3 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
