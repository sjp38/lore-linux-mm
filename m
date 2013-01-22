Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx168.postini.com [74.125.245.168])
	by kanga.kvack.org (Postfix) with SMTP id 26B4F6B0010
	for <linux-mm@kvack.org>; Tue, 22 Jan 2013 06:47:12 -0500 (EST)
From: Tang Chen <tangchen@cn.fujitsu.com>
Subject: [PATCH Bug fix 0/4] Bug fix for movablecore_map boot option.
Date: Tue, 22 Jan 2013 19:46:17 +0800
Message-Id: <1358855181-6160-1-git-send-email-tangchen@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rientjes@google.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, cl@linux.com, minchan.kim@gmail.com, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, wujianguo@huawei.com, wency@cn.fujitsu.com, hpa@zytor.com, linfeng@cn.fujitsu.com, laijs@cn.fujitsu.com, mgorman@suse.de, yinghai@kernel.org, glommer@parallels.com, jiang.liu@huawei.com, julian.calaby@gmail.com, sfr@canb.auug.org.au
Cc: x86@kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, linuxppc-dev@lists.ozlabs.org, linux-acpi@vger.kernel.org

Hi Andrew,

patch1 ~ patch3 fix some problems of movablecore_map boot option.
And since the name "core" could be confused, patch4 rename this option
to movablemem_map.

All these patches are based on the latest -mm tree.
git://git.kernel.org/pub/scm/linux/kernel/git/next/linux-next.git akpm

Tang Chen (4):
  Bug fix: Use CONFIG_HAVE_MEMBLOCK_NODE_MAP to protect movablecore_map
    in memblock_overlaps_region().
  Bug fix: Fix the doc format.
  Bug fix: Remove the unused sanitize_zone_movable_limit() definition.
  Rename movablecore_map to movablemem_map.

 Documentation/kernel-parameters.txt |    8 +-
 include/linux/memblock.h            |    3 +-
 include/linux/mm.h                  |    8 +-
 mm/memblock.c                       |   42 +++++++++++-
 mm/page_alloc.c                     |  116 +++++++++++++++++-----------------
 5 files changed, 106 insertions(+), 71 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
