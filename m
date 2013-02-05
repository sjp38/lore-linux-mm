Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx155.postini.com [74.125.245.155])
	by kanga.kvack.org (Postfix) with SMTP id 560106B0008
	for <linux-mm@kvack.org>; Tue,  5 Feb 2013 12:10:06 -0500 (EST)
Received: by mail-da0-f52.google.com with SMTP id f10so141637dak.25
        for <linux-mm@kvack.org>; Tue, 05 Feb 2013 09:10:05 -0800 (PST)
Message-ID: <51113CE3.5090000@gmail.com>
Date: Wed, 06 Feb 2013 01:09:55 +0800
From: Zhang Yanfei <zhangyanfei.yes@gmail.com>
MIME-Version: 1.0
Subject: [PATCH 0/3] mm: rename confusing function names
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Linux MM <linux-mm@kvack.org>, mgorman@suse.de, minchan@kernel.org, kamezawa.hiroyu@jp.fujitsu.com, m.szyprowski@samsung.com
Cc: linux-kernel@vger.kernel.org

Function nr_free_zone_pages, nr_free_buffer_pages and nr_free_pagecache_pages
are horribly badly named, they count present_pages - pages_high within zones
instead of free pages, so why not rename them to reasonable names, not cofusing
people.

patch2 and patch3 are based on patch1. So please apply patch1 first.

Zhang Yanfei (3):
  mm: rename nr_free_zone_pages to nr_free_zone_high_pages
  mm: rename nr_free_buffer_pages to nr_free_buffer_high_pages
  mm: rename nr_free_pagecache_pages to nr_free_pagecache_high_pages

 arch/ia64/mm/contig.c          |    3 ++-
 arch/ia64/mm/discontig.c       |    3 ++-
 drivers/mmc/card/mmc_test.c    |    4 ++--
 fs/buffer.c                    |    2 +-
 fs/nfsd/nfs4state.c            |    2 +-
 fs/nfsd/nfssvc.c               |    2 +-
 include/linux/swap.h           |    4 ++--
 mm/huge_memory.c               |    2 +-
 mm/memory_hotplug.c            |    4 ++--
 mm/page-writeback.c            |    2 +-
 mm/page_alloc.c                |   22 ++++++++++++----------
 net/9p/trans_virtio.c          |    2 +-
 net/ipv4/tcp.c                 |    4 ++--
 net/ipv4/udp.c                 |    2 +-
 net/netfilter/ipvs/ip_vs_ctl.c |    2 +-
 net/sctp/protocol.c            |    2 +-
 16 files changed, 33 insertions(+), 29 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
