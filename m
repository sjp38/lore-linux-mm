Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx169.postini.com [74.125.245.169])
	by kanga.kvack.org (Postfix) with SMTP id C6F7C6B0071
	for <linux-mm@kvack.org>; Wed,  4 Jul 2012 03:25:56 -0400 (EDT)
From: Lai Jiangshan <laijs@cn.fujitsu.com>
Subject: [RFC PATCH 0/3 V1] mm: add new migrate type and online_movable for hotplug
Date: Wed, 4 Jul 2012 15:26:15 +0800
Message-Id: <1341386778-8002-1-git-send-email-laijs@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Mel Gorman <mel@csn.ul.ie>
Cc: Chris Metcalf <cmetcalf@tilera.com>, --@kvack.org, Len Brown <lenb@kernel.org>--@kvack.org, Greg Kroah-Hartman <gregkh@linuxfoundation.org>--@kvack.org, Andi Kleen <andi@firstfloor.org>--@kvack.org, Julia Lawall <julia@diku.dk>--@kvack.org, David Howells <dhowells@redhat.com>--@kvack.org, Lai Jiangshan <laijs@cn.fujitsu.com>--@kvack.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>--@kvack.org, Kay Sievers <kay.sievers@vrfy.org>--@kvack.org, Ingo Molnar <mingo@elte.hu>--@kvack.org, Paul Gortmaker <paul.gortmaker@windriver.com>--@kvack.org, Daniel Kiper <dkiper@net-space.pl>--@kvack.org, Andrew Morton <akpm@linux-foundation.org>--@kvack.org, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>--@kvack.org, Michal Hocko <mhocko@suse.cz>--@kvack.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>--@kvack.org, Minchan Kim <minchan@kernel.org>--@kvack.org, Michal Nazarewicz <mina86@mina86.com>--@kvack.org, Marek Szyprowski <m.szyprowski@samsung.com>--@kvack.org, Rik van Riel <riel@redhat.com>--@kvack.org, Bjorn Helgaas <bhelgaas@google.com>--@kvack.org, Christoph Lameter <cl@linux.com>--@kvack.org, David Rientjes <rientjes@google.com>--@kvack.org, linux-kernel@vger.kernel.org--, linux-acpi@vger.kernel.org--, linux-mm@kvack.org

The 1st patch fixes the allocation of CMA and prepares for movable-like types.

The 2nd patch add a new migrate type which stands for the movable types which
pages will not be changed to the other type.

I chose the name MIGRATE_HOTREMOVE from MIGRATE_HOTREMOVE
and MIGRATE_MOVABLE_STABLE, it just because the first usecase of this new type
is for hotremove.

The 3th path introduces online_movable. When a memoryblock is onlined
by "online_movable", the kernel will not have directly reference to the page
of the memoryblock, thus we can remove that memory any time when needed.

Different from ZONE_MOVABLE: it can be used for any given memroyblock.

Lai Jiangshan (3):
  use __rmqueue_smallest when borrow memory from MIGRATE_CMA
  add MIGRATE_HOTREMOVE type
  add online_movable

 arch/tile/mm/init.c            |    2 +-
 drivers/acpi/acpi_memhotplug.c |    3 +-
 drivers/base/memory.c          |   24 +++++++----
 include/linux/memory.h         |    1 +
 include/linux/memory_hotplug.h |    4 +-
 include/linux/mmzone.h         |   37 +++++++++++++++++
 include/linux/page-isolation.h |    2 +-
 mm/compaction.c                |    6 +-
 mm/memory-failure.c            |    8 +++-
 mm/memory_hotplug.c            |   36 +++++++++++++---
 mm/page_alloc.c                |   86 ++++++++++++++++-----------------------
 mm/vmstat.c                    |    3 +
 12 files changed, 136 insertions(+), 76 deletions(-)

-- 
1.7.4.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
