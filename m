Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx185.postini.com [74.125.245.185])
	by kanga.kvack.org (Postfix) with SMTP id 297676B0009
	for <linux-mm@kvack.org>; Thu, 21 Feb 2013 03:18:36 -0500 (EST)
Received: by mail-da0-f49.google.com with SMTP id t11so3960938daj.22
        for <linux-mm@kvack.org>; Thu, 21 Feb 2013 00:18:35 -0800 (PST)
Date: Thu, 21 Feb 2013 00:17:48 -0800 (PST)
From: Hugh Dickins <hughd@google.com>
Subject: [PATCH 0/7] ksm: responses to NUMA review
Message-ID: <alpine.LNX.2.00.1302210013120.17843@eggly.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Mel Gorman <mgorman@suse.de>, Petr Holasek <pholasek@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Izik Eidus <izik.eidus@ravellosystems.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org

Here's a second KSM series, based on mmotm 2013-02-19-17-20: partly in
response to Mel's review feedback, partly fixes to issues that I found
myself in doing more review and testing.  None of the issues fixed are
truly show-stoppers, though I would prefer them fixed sooner than later.

1 ksm: add some comments
2 ksm: treat unstable nid like in stable tree
3 ksm: shrink 32-bit rmap_item back to 32 bytes
4 mm,ksm: FOLL_MIGRATION do migration_entry_wait
5 mm,ksm: swapoff might need to copy
6 mm: cleanup "swapcache" in do_swap_page
7 ksm: allocate roots when needed

 Documentation/vm/ksm.txt |   16 +++-
 include/linux/mm.h       |    1 
 mm/ksm.c                 |  137 +++++++++++++++++++++++--------------
 mm/memory.c              |   38 +++++++---
 mm/swapfile.c            |   15 +++-
 5 files changed, 140 insertions(+), 67 deletions(-)

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
