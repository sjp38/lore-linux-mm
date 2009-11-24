Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 6D44E6B007B
	for <linux-mm@kvack.org>; Tue, 24 Nov 2009 11:38:06 -0500 (EST)
Date: Tue, 24 Nov 2009 16:37:42 +0000 (GMT)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/9] ksm: swapping
Message-ID: <Pine.LNX.4.64.0911241634170.24427@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Izik Eidus <ieidus@redhat.com>, Andrea Arcangeli <aarcange@redhat.com>, Chris Wright <chrisw@redhat.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Here is a series of nine patches against 2.6.32-rc7-mm1, at last making
KSM's shared pages swappable.  The main patches, 2 3 and 4, have been
around for over a month; but I underestimated the tail of the job,
working out the right compromises to deal with the consequences of
having ksm pages on the LRUs.

 Documentation/vm/ksm.txt |   22 -
 include/linux/ksm.h      |   71 ++++
 include/linux/migrate.h  |    8 
 include/linux/rmap.h     |   35 ++
 mm/Kconfig               |    2 
 mm/internal.h            |    3 
 mm/ksm.c                 |  567 ++++++++++++++++++++++++++++---------
 mm/memcontrol.c          |    7 
 mm/memory.c              |    6 
 mm/memory_hotplug.c      |    2 
 mm/mempolicy.c           |   19 -
 mm/migrate.c             |  112 ++-----
 mm/mlock.c               |    4 
 mm/rmap.c                |  151 +++++++--
 mm/swapfile.c            |   11 
 15 files changed, 741 insertions(+), 279 deletions(-)

Thanks!
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
