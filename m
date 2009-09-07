Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 4FEBA6B00B1
	for <linux-mm@kvack.org>; Mon,  7 Sep 2009 17:27:30 -0400 (EDT)
Date: Mon, 7 Sep 2009 22:26:51 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/8] mm: around get_user_pages flags
Message-ID: <Pine.LNX.4.64.0909072222070.15424@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, Linus Torvalds <torvalds@linux-foundation.org>, Nick Piggin <npiggin@suse.de>, Rik van Riel <riel@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here's a series of mm mods against current mmotm: mostly cleanup
of get_user_pages flags, but fixing munlock's OOM, sorting out the
"FOLL_ANON optimization", and reinstating ZERO_PAGE along the way.

 fs/binfmt_elf.c         |   42 ++------
 fs/binfmt_elf_fdpic.c   |   56 ++++-------
 include/linux/hugetlb.h |    4 
 include/linux/mm.h      |    4 
 mm/hugetlb.c            |   62 +++++++------
 mm/internal.h           |    7 -
 mm/memory.c             |  180 +++++++++++++++++++++++---------------
 mm/mlock.c              |   99 ++++++++------------
 mm/nommu.c              |   22 ++--
 9 files changed, 235 insertions(+), 241 deletions(-)

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
