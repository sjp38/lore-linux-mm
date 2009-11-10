Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id EEF8C6B004D
	for <linux-mm@kvack.org>; Tue, 10 Nov 2009 17:36:44 -0500 (EST)
Subject: [PATCH v3 0/5] 
From: Alex Chiang <achiang@hp.com>
Date: Tue, 10 Nov 2009 15:36:38 -0700
Message-ID: <20091110223154.25636.48462.stgit@bob.kio>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com
List-ID: <linux-mm.kvack.org>

This is v3 of the series.

I based it off of Linus's latest tree. 

I did not include David Rientjes's "mm: slab allocate memory section nodemask
for large systems" patch in my series, since it's not necessarily related.

Please consider for inclusion for the next merge window (v2.6.33).

Thanks,
/ac

v2 -> v3:
	- rebased to Linus's latest tree (799dd75b)
	- Added David Rientjes's Acked-by: flags
	- dropped S390 cc's, since they are unaffected by this series

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
 Documentation/ABI/testing/sysfs-devices-system-cpu |   14 +++++
 Documentation/memory-hotplug.txt                   |   11 ++--
 drivers/base/node.c                                |   58 ++++++++++++++------
 4 files changed, 76 insertions(+), 21 deletions(-)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
