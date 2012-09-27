Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx156.postini.com [74.125.245.156])
	by kanga.kvack.org (Postfix) with SMTP id B2ECE6B0044
	for <linux-mm@kvack.org>; Thu, 27 Sep 2012 01:39:25 -0400 (EDT)
From: wency@cn.fujitsu.com
Subject: [PATCH 0/4] bugfix for memory hotplug
Date: Thu, 27 Sep 2012 13:45:01 +0800
Message-Id: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org, kosaki.motohiro@jp.fujitsu.com, isimatu.yasuaki@jp.fujitsu.com, Wen Congyang <wency@cn.fujitsu.com>

From: Wen Congyang <wency@cn.fujitsu.com>

Wen Congyang (2):
  memory-hotplug: clear hwpoisoned flag when onlining pages
  memory-hotplug: auto offline page_cgroup when onlining memory block
    failed

Yasuaki Ishimatsu (2):
  memory-hotplug: add memory_block_release
  memory-hotplug: add node_device_release

 drivers/base/memory.c |    9 ++++++++-
 drivers/base/node.c   |   11 +++++++++++
 mm/memory_hotplug.c   |    8 ++++++++
 mm/page_cgroup.c      |    3 +++
 4 files changed, 30 insertions(+), 1 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
