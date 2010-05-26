Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id E27F06B01B5
	for <linux-mm@kvack.org>; Wed, 26 May 2010 15:42:16 -0400 (EDT)
Date: Wed, 26 May 2010 15:38:19 -0400
From: Rik van Riel <riel@redhat.com>
Subject: [PATCH -v3 0/5] always lock the root anon_vma
Message-ID: <20100526153819.6e5cec0d@annuminas.surriel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Mel Gorman <mel@csn.ul.ie>, Andrea Arcangeli <aarcange@redhat.com>, Minchan Kim <minchan.kim@gmail.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Lee Schermerhorn <Lee.Schermerhorn@hp.com>
List-ID: <linux-mm.kvack.org>

Andrew, here are the patches to always lock the root anon_vma,
ported to the latest -mm tree.

These patches implement Linus's idea of always locking the root
anon_vma and contain all the fixes and improvements suggested 
by Andrea.

This should fix the last bits of the anon_vma locking.

v3 is identical to v2, except I gathered up the Acked-by:s that
were on list already.

Patches 4 and 5 still need some reviewing and acks...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
