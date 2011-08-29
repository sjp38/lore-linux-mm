From: Minchan Kim <minchan.kim@gmail.com>
Subject: [PATCH 0/3] Fix compaction about mlocked pages
Date: Mon, 29 Aug 2011 16:43:02 +0000 (UTC)
Message-ID: <cover.1321112552.git.minchan.kim__11087.648678995$1314636181$gmane$org@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Date: Sun, 13 Nov 2011 01:37:40 +0900
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm <linux-mm@kvack.org>, LKML <linux-kernel@vger.kernel.org>, Mel Gorman <mgorman@suse.de>, Johannes Weiner <jweiner@redhat.com>, Rik van Riel <riel@redhat.com>, Minchan Kim <minchan.kim@gmail.com>
List-Id: linux-mm.kvack.org

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
