From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 0/2] Use up free swap space before reaching OOM kill
Date: Wed,  9 Jan 2013 15:21:12 +0900
Message-ID: <1357712474-27595-1-git-send-email-minchan@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, Dan Magenheimer <dan.magenheimer@oracle.com>, Sonny Rao <sonnyrao@google.com>, Bryan Freed <bfreed@google.com>, Hugh Dickins <hughd@google.com>, Rik van Riel <riel@redhat.com>, Johannes Weiner <hannes@cmpxchg.org>, Minchan Kim <minchan@kernel.org>
List-Id: linux-mm.kvack.org

Recently, Luigi reported there are lots of free swap space when
OOM happens. It's easily reproduced on zram-over-swap, where
many instance of memory hogs are running and laptop_mode = 2.
http://marc.info/?l=linux-mm&m=135421750914807&w=2

This patchset fixes the problem. In fact, if we apply one of two,
we can fix the problem but I send two all because it's separate
issue although each of them solves this issues.

Andrew, Could you replace [1] with this patchset in mmotm?
I think this patchset is better than [1].

[1] mm-swap-out-anonymous-page-regardless-of-laptop_mode.patch

Minchan Kim (2):
  [1/2] mm: prevent to add a page to swap if may_writepage is unset
  [2/2] mm: forcely swapout when we are out of page cache

 mm/vmscan.c |    8 ++++++++
 1 file changed, 8 insertions(+)

-- 
1.7.9.5
