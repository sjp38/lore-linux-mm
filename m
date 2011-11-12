Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta7.messagelabs.com (mail6.bemta7.messagelabs.com [216.82.255.55])
	by kanga.kvack.org (Postfix) with ESMTP id D84F6900137
	for <linux-mm@kvack.org>; Mon, 29 Aug 2011 12:42:37 -0400 (EDT)
Received: by iagv1 with SMTP id v1so839773iag.14
        for <linux-mm@kvack.org>; Mon, 29 Aug 2011 09:42:31 -0700 (PDT)
From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 0/3] Fix compaction about mlocked pages
Date: Sun, 13 Nov 2011 01:37:40 +0900
Message-Id: <cover.1321112552.git.minchan.kim@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>

This patch's goal is to enable mlocked page migration.
The compaction can migrate mlocked page to get a contiguous memory unlike lumpy.

During making this patch, I found my silly bug which
[1/3] which fixes it.
[2/3] enables compaction of mlocked.
[3/3] enhance the accouting of compaction.

Frankly speaking, each patch is orthogonal but I send it by thread as I found them during
making patch on mlocked page compaction.

Minchan Kim (3):
  Correct isolate_mode_t bitwise type
  compaction: compact unevictable page
  compaction accouting fix

 include/linux/mmzone.h |   10 ++++++----
 mm/compaction.c        |   13 +++++++++----
 mm/vmscan.c            |    7 +------
 3 files changed, 16 insertions(+), 14 deletions(-)

--
1.7.6

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
