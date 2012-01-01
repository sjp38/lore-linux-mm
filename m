Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx179.postini.com [74.125.245.179])
	by kanga.kvack.org (Postfix) with SMTP id 80DD46B009C
	for <linux-mm@kvack.org>; Sun,  1 Jan 2012 02:39:09 -0500 (EST)
Received: by iacb35 with SMTP id b35so33327046iac.14
        for <linux-mm@kvack.org>; Sat, 31 Dec 2011 23:39:08 -0800 (PST)
Date: Sat, 31 Dec 2011 23:39:06 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/6] mm: trivial cleanups
Message-ID: <alpine.LSU.2.00.1112312333380.18500@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Johannes Weiner <hannes@cmpxchg.org>, KOSAKI Motohiro <kosaki.motohiro@gmail.com>, linux-mm@kvack.org

Six trivial cleanups to some mm files, mainly swap.c and vmscan.c.
The last less trivial than the others, renaming putback_lru_pages and
rearranging a little of the stats updating.  That one does assume my
"mm: take pagevecs off reclaim stack" is still in mmotm/next: should
be easy to settle its lock-hold-time if that's still a worry.

(I did have a patch to factor isolate_lumpy_pages out of isolate_lru_pages;
but lumpy remains a battleground of frequent little fixups, so I think it
will be easier for everyone if I leave it as is for now, and cope with
the deep indentation later on.)

[PATCH 1/6] mm: fewer underscores in ____pagevec_lru_add
[PATCH 2/6] mm: no blank line after EXPORT_SYMBOL in swap.c
[PATCH 3/6] mm: enum lru_list lru
[PATCH 4/6] mm: remove del_page_from_lru, add page_off_lru
[PATCH 5/6] mm: remove isolate_pages
[PATCH 6/6] mm: rearrange putback_inactive_pages

 include/linux/mm_inline.h |   37 ++++---
 include/linux/mmzone.h    |   16 +--
 include/linux/pagevec.h   |   10 +-
 mm/page_alloc.c           |    6 -
 mm/swap.c                 |   21 +---
 mm/vmscan.c               |  179 ++++++++++++++++--------------------
 6 files changed, 126 insertions(+), 143 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
