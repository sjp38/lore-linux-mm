Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 5F1676B004F
	for <linux-mm@kvack.org>; Mon, 19 Oct 2009 17:34:12 -0400 (EDT)
Subject: [PATCH 0/5] mm: modest useability enhancements for node sysfs attrs
From: Alex Chiang <achiang@hp.com>
Date: Mon, 19 Oct 2009 15:34:10 -0600
Message-ID: <20091019212740.32729.7171.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

I've been poking at memory/node hotplug lately, and found myself wondering
what node a memory section or CPU might belong to.

Yes, the information is there in sysfs, but to me, having a symlink pointing
back to the node is so much more convenient.

Thanks,
/ac

---

Alex Chiang (5):
      mm: add numa node symlink for memory section in sysfs
      mm: refactor register_cpu_under_node()
      mm: refactor unregister_cpu_under_node()
      mm: add numa node symlink for cpu devices in sysfs
      Documentation: ABI: document /sys/devices/system/cpu/


 Documentation/ABI/testing/sysfs-devices-cpu    |   42 ++++++++++++++++++
 Documentation/ABI/testing/sysfs-devices-memory |   14 ++++++
 Documentation/memory-hotplug.txt               |   11 +++--
 drivers/base/node.c                            |   56 +++++++++++++++++-------
 4 files changed, 102 insertions(+), 21 deletions(-)
 create mode 100644 Documentation/ABI/testing/sysfs-devices-cpu

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
