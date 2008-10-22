Message-Id: <20081022225006.010250557@saeurebad.de>
Date: Thu, 23 Oct 2008 00:50:06 +0200
From: Johannes Weiner <hannes@saeurebad.de>
Subject: [patch 0/3] activate pages in batch
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Rik van Riel <riel@redhat.com>, Peter Zijlstra <peterz@infradead.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Instead of re-acquiring the highly contented LRU lock on every single
page activation, deploy an extra pagevec to do page activation in
batch.

The first patch is just grouping all pagevecs we use into one array
which makes further refactoring easier.

The second patch simplifies the interface for flushing a pagevec to
the proper LRU list.

And finally, the last patch changes page activation to batch-mode.

	Hannes

 include/linux/pagevec.h |   21 +++-
 mm/swap.c               |  216 ++++++++++++++++++++++++------------------------
 2 files changed, 127 insertions(+), 110 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
