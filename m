Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx201.postini.com [74.125.245.201])
	by kanga.kvack.org (Postfix) with SMTP id F1BC06B0002
	for <linux-mm@kvack.org>; Wed, 20 Mar 2013 14:03:43 -0400 (EDT)
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: [patch 0/5] sparse-vmemmap: hotplug fixes & cleanups
Date: Wed, 20 Mar 2013 14:03:27 -0400
Message-Id: <1363802612-32127-1-git-send-email-hannes@cmpxchg.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: x86@kernel.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Ben Hutchings <ben@decadent.org.uk>, linux-mm@kvack.org, linux-arch@vger.kernel.org, linux-kernel@vger.kernel.org

Hotplug can happen at times when the memory situation is less than
perfect to allocate huge pages for the vmemmap.  This series makes the
allocation try harder in patch #1.  The remaining patches allow x86-64
to fall back to regular pages as a last resort before the hotplug
event fails completely.  As a prerequisite to this, the arch interface
to sparse is cleaned up a little, which should also enable other
architectures to easily mix huge and regular pages in the vmemmap.

 arch/arm64/mm/mmu.c       | 13 +++++--------
 arch/ia64/mm/discontig.c  |  7 +++----
 arch/powerpc/mm/init_64.c | 11 +++--------
 arch/s390/mm/vmem.c       | 13 +++++--------
 arch/sparc/mm/init_64.c   |  7 +++----
 arch/x86/mm/init_64.c     | 68 ++++++++++++++++++++++++++++++++------------------------------------
 include/linux/mm.h        |  8 ++++----
 mm/sparse-vmemmap.c       | 27 +++++++++++++++++----------
 mm/sparse.c               | 10 ++++++++--
 9 files changed, 80 insertions(+), 84 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
