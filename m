Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f174.google.com (mail-ie0-f174.google.com [209.85.223.174])
	by kanga.kvack.org (Postfix) with ESMTP id 093EE6B017D
	for <linux-mm@kvack.org>; Wed, 11 Jun 2014 18:15:16 -0400 (EDT)
Received: by mail-ie0-f174.google.com with SMTP id lx4so399745iec.19
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:15:15 -0700 (PDT)
Received: from mail-ig0-x22d.google.com (mail-ig0-x22d.google.com [2607:f8b0:4001:c05::22d])
        by mx.google.com with ESMTPS id ii4si46367629icc.34.2014.06.11.15.15.15
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 11 Jun 2014 15:15:15 -0700 (PDT)
Received: by mail-ig0-f173.google.com with SMTP id r2so5043673igi.6
        for <linux-mm@kvack.org>; Wed, 11 Jun 2014 15:15:15 -0700 (PDT)
Date: Wed, 11 Jun 2014 15:15:13 -0700 (PDT)
From: David Rientjes <rientjes@google.com>
Subject: [patch] mm, hotplug: probe interface is available on several
 platforms
In-Reply-To: <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com>
Message-ID: <alpine.DEB.2.02.1406111511450.27885@chino.kir.corp.google.com>
References: <53981D81.5060708@huawei.com> <alpine.DEB.2.02.1406111503050.27885@chino.kir.corp.google.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Dave Hansen <dave.hansen@intel.com>, Zhang Zhen <zhenzhang.zhang@huawei.com>, Greg Kroah-Hartman <gregkh@linuxfoundation.org>, laijs@cn.fujitsu.com, sjenning@linux.vnet.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Wang Nan <wangnan0@huawei.com>

Documentation/memory-hotplug.txt incorrectly states that the memory driver 
"probe" interface is only supported on powerpc and is vague about its 
application on x86.  Clarify the platforms that make this interface 
available if memory hotplug is enabled.

Signed-off-by: David Rientjes <rientjes@google.com>
---
 Documentation/memory-hotplug.txt | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/Documentation/memory-hotplug.txt b/Documentation/memory-hotplug.txt
--- a/Documentation/memory-hotplug.txt
+++ b/Documentation/memory-hotplug.txt
@@ -209,15 +209,12 @@ If memory device is found, memory hotplug code will be called.
 
 4.2 Notify memory hot-add event by hand
 ------------
-On powerpc, the firmware does not notify a memory hotplug event to the kernel.
-Therefore, "probe" interface is supported to notify the event to the kernel.
-This interface depends on CONFIG_ARCH_MEMORY_PROBE.
-
-CONFIG_ARCH_MEMORY_PROBE is supported on powerpc only. On x86, this config
-option is disabled by default since ACPI notifies a memory hotplug event to
-the kernel, which performs its hotplug operation as the result. Please
-enable this option if you need the "probe" interface for testing purposes
-on x86.
+On some architectures, the firmware may not notify the kernel of a memory
+hotplug event.  Therefore, the memory "probe" interface is supported to
+explicitly notify the kernel.  This interface depends on
+CONFIG_ARCH_MEMORY_PROBE and can be configured on powerpc, sh, and x86
+if hotplug is supported, although for x86 this should be handled by ACPI
+notification.
 
 Probe interface is located at
 /sys/devices/system/memory/probe

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
