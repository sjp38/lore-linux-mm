Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with ESMTP id 8C4B06B004D
	for <linux-mm@kvack.org>; Thu, 22 Oct 2009 00:15:07 -0400 (EDT)
Subject: [PATCH v2 0/5] mm: modest useability enhancements for node sysfs attrs
From: Alex Chiang <achiang@hp.com>
Date: Wed, 21 Oct 2009 22:15:05 -0600
Message-ID: <20091022040814.15705.95572.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is v2 of the series.

The last patch in this series is dependent upon the documentation patch
series that I just sent out a few moments ago:

	http://thread.gmane.org/gmane.linux.kernel/905018

Thanks,
/ac


v1 -> v2: http://thread.gmane.org/gmane.linux.kernel.mm/40084/
	Address David Rientjes's comments
	- check return value of sysfs_create_link in register_cpu_under_node
	- do /not/ convert [un]register_cpu_under_node to return void, since
	  sparse starts whinging if you ignore sysfs_create_link()'s return
	  value and working around sparse makes the code ugly
	- adjust documentation

	Added S390 maintainers to cc: for patch [1/5] as per Kame-san's
	suggestion. S390 may map a memory section to more than one node,
	causing this series to break.

---

Alex Chiang (5):
      mm: add numa node symlink for memory section in sysfs
      mm: refactor register_cpu_under_node()
      mm: refactor unregister_cpu_under_node()
      mm: add numa node symlink for cpu devices in sysfs
      Documentation: ABI: /sys/devices/system/cpu/cpu#/node


 Documentation/ABI/testing/sysfs-devices-memory     |   14 ++++-
 Documentation/ABI/testing/sysfs-devices-system-cpu |   15 +++++
 Documentation/memory-hotplug.txt                   |   11 ++--
 drivers/base/node.c                                |   58 ++++++++++++++------
 4 files changed, 77 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
