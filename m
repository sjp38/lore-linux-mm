Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx149.postini.com [74.125.245.149])
	by kanga.kvack.org (Postfix) with SMTP id 5587B6B0068
	for <linux-mm@kvack.org>; Tue, 15 Jan 2013 05:55:37 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [BUG Fix Patch 0/6] Bug fix for physical memory hot-remove.
Date: Tue, 15 Jan 2013 18:54:21 +0800
Message-Id: <1358247267-18089-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, tangchen@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org, linux-s390@vger.kernel.org, linux-sh@vger.kernel.org, linux-ia64@vger.kernel.org, cmetcalf@tilera.com, sparclinux@vger.kernel.org

Hi Andrew,

Here are some bug fix patches for physical hot-remove patches.
And there are some new ones reported by others, I'll fix them soon.

Thanks. :)


Tang Chen (6):
  Bug fix: Hold spinlock across find|remove /sys/firmware/memmap/X
    operation.
  Bug fix: Do not calculate direct mapping pages when freeing vmemmap
    pagetables.
  Bug fix: Do not free direct mapping pages twice.
  Bug fix: Do not free page split from hugepage one by one.
  Bug fix: Fix the wrong comments of map_entries.
  Bug fix: Reuse the storage of /sys/firmware/memmap/X/ allocated by
    bootmem.

 arch/x86/mm/init_64.c     |   92 ++++++++++++++++++++++++++++-----
 drivers/firmware/memmap.c |  124 ++++++++++++++++++++++++++++++++++++--------
 2 files changed, 179 insertions(+), 37 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
