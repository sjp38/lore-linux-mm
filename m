Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx164.postini.com [74.125.245.164])
	by kanga.kvack.org (Postfix) with SMTP id 8FE836B0002
	for <linux-mm@kvack.org>; Mon, 15 Apr 2013 05:43:55 -0400 (EDT)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH 0/3] Little error fix and cleanup.
Date: Mon, 15 Apr 2013 17:46:44 +0800
Message-Id: <1366019207-27818-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: gregkh@linuxfoundation.org, tglx@linutronix.de, mingo@redhat.com, hpa@zytor.com, yinghai@kernel.org, akpm@linux-foundation.org, wency@cn.fujitsu.com, mgorman@suse.de, tj@kernel.org, liwanp@linux.vnet.ibm.com
Cc: tangchen@cn.fujitsu.com, linux-mm@kvack.org, x86@kernel.org, linux-kernel@vger.kernel.org

This patch-set did the following things:

patch1: Remove unused parameter "nr_pages" of pages_correctly_reserved().
patch2: Use CONFIG_MEMORY_HOTREMOVE to protect kernel_physical_mapping_remove().
patch3: Add comments for parameter "nid" for memblock_insert_region().

Tang Chen (3):
  mm: Remove unused parameter of pages_correctly_reserved().
  mem-hotplug: Put kernel_physical_mapping_remove() declaration in
    CONFIG_MEMORY_HOTREMOVE.
  memblock: Fix missing comment of memblock_insert_region().

 arch/x86/mm/init_64.c |    2 +-
 drivers/base/memory.c |    5 ++---
 mm/memblock.c         |    9 +++++----
 3 files changed, 8 insertions(+), 8 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
