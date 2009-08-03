Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with SMTP id E0F4A6B005A
	for <linux-mm@kvack.org>; Mon,  3 Aug 2009 07:49:10 -0400 (EDT)
Date: Mon, 3 Aug 2009 13:08:23 +0100 (BST)
From: Hugh Dickins <hugh.dickins@tiscali.co.uk>
Subject: [PATCH 0/12] ksm: stats, oom, doc, misc
Message-ID: <Pine.LNX.4.64.0908031304430.16449@sister.anvils>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Izik Eidus <ieidus@redhat.com>
Cc: Andrea Arcangeli <aarcange@redhat.com>, Rik van Riel <riel@redhat.com>, Chris Wright <chrisw@redhat.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi Izik,

Here's a set of twelve patches, which I think complete what I want
to do with KSM for current mmotm and 2.6.32: it's as I sent you in
a rollup last week, but with 1/12 and 10/12 added.  Patches apply
to 2.6.31-rc5 plus our previous ten KSM patches, or to mmotm which
already includes those.

[PATCH  1/12] ksm: rename kernel_pages_allocated
[PATCH  2/12] ksm: move pages_sharing updates
[PATCH  3/12] ksm: pages_unshared and pages_volatile
[PATCH  4/12] ksm: break cow once unshared
[PATCH  5/12] ksm: keep quiet while list empty
[PATCH  6/12] ksm: five little cleanups
[PATCH  7/12] ksm: fix endless loop on oom
[PATCH  8/12] ksm: distribute remove_mm_from_lists
[PATCH  9/12] ksm: fix oom deadlock
[PATCH 10/12] ksm: sysfs and defaults
[PATCH 11/12] ksm: add some documentation
[PATCH 12/12] ksm: remove VM_MERGEABLE_FLAGS

 Documentation/vm/00-INDEX |    2 
 Documentation/vm/ksm.txt  |   89 +++++
 include/linux/ksm.h       |   31 +
 kernel/fork.c             |    1 
 mm/Kconfig                |    1 
 mm/ksm.c                  |  574 ++++++++++++++++++++++--------------
 mm/memory.c               |    5 
 mm/mmap.c                 |   15 
 8 files changed, 498 insertions(+), 220 deletions(-)

If you and others are happy with these, please send them on to Andrew
(or else just point him to them); if not, then let's fix them first.

Thanks,
Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
