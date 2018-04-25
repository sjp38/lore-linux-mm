Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id D16A56B0003
	for <linux-mm@kvack.org>; Wed, 25 Apr 2018 16:02:07 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id l8-v6so15989043qtb.11
        for <linux-mm@kvack.org>; Wed, 25 Apr 2018 13:02:07 -0700 (PDT)
Received: from mx1.redhat.com (mx3-rdu2.redhat.com. [66.187.233.73])
        by mx.google.com with ESMTPS id s6si4768103qkc.12.2018.04.25.13.02.06
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 25 Apr 2018 13:02:06 -0700 (PDT)
Date: Wed, 25 Apr 2018 16:02:00 -0400 (EDT)
From: Mikulas Patocka <mpatocka@redhat.com>
Subject: [PATCH] fault-injection: reorder config entries
In-Reply-To: <20180424173836.GR17484@dhcp22.suse.cz>
Message-ID: <alpine.LRH.2.02.1804251601160.30569@file01.intranet.prod.int.rdu2.redhat.com>
References: <20180421144757.GC14610@bombadil.infradead.org> <alpine.LRH.2.02.1804221733520.7995@file01.intranet.prod.int.rdu2.redhat.com> <20180423151545.GU17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804232003100.2299@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424125121.GA17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241142340.15660@file01.intranet.prod.int.rdu2.redhat.com> <20180424162906.GM17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241250350.28995@file01.intranet.prod.int.rdu2.redhat.com>
 <20180424170349.GQ17484@dhcp22.suse.cz> <alpine.LRH.2.02.1804241319390.28995@file01.intranet.prod.int.rdu2.redhat.com> <20180424173836.GR17484@dhcp22.suse.cz>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@kernel.org>
Cc: Matthew Wilcox <willy@infradead.org>, David Miller <davem@davemloft.net>, Andrew Morton <akpm@linux-foundation.org>, linux-mm@kvack.org, eric.dumazet@gmail.com, edumazet@google.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org, mst@redhat.com, jasowang@redhat.com, virtualization@lists.linux-foundation.org, dm-devel@redhat.com, Vlastimil Babka <vbabka@suse.cz>

This patch reorders Kconfig entries, so that menuconfig displays proper 
indentation.

Signed-off-by: Mikulas Patocka <mpatocka@redhat.com>

---
 lib/Kconfig.debug |   36 ++++++++++++++++++------------------
 1 file changed, 18 insertions(+), 18 deletions(-)

Index: linux-2.6/lib/Kconfig.debug
===================================================================
--- linux-2.6.orig/lib/Kconfig.debug	2018-04-16 21:08:36.000000000 +0200
+++ linux-2.6/lib/Kconfig.debug	2018-04-25 15:56:16.000000000 +0200
@@ -1503,6 +1503,10 @@ config NETDEV_NOTIFIER_ERROR_INJECT
 
 	  If unsure, say N.
 
+config FUNCTION_ERROR_INJECTION
+	def_bool y
+	depends on HAVE_FUNCTION_ERROR_INJECTION && KPROBES
+
 config FAULT_INJECTION
 	bool "Fault-injection framework"
 	depends on DEBUG_KERNEL
@@ -1510,10 +1514,6 @@ config FAULT_INJECTION
 	  Provide fault-injection framework.
 	  For more details, see Documentation/fault-injection/.
 
-config FUNCTION_ERROR_INJECTION
-	def_bool y
-	depends on HAVE_FUNCTION_ERROR_INJECTION && KPROBES
-
 config FAILSLAB
 	bool "Fault-injection capability for kmalloc"
 	depends on FAULT_INJECTION
@@ -1544,16 +1544,6 @@ config FAIL_IO_TIMEOUT
 	  Only works with drivers that use the generic timeout handling,
 	  for others it wont do anything.
 
-config FAIL_MMC_REQUEST
-	bool "Fault-injection capability for MMC IO"
-	depends on FAULT_INJECTION_DEBUG_FS && MMC
-	help
-	  Provide fault-injection capability for MMC IO.
-	  This will make the mmc core return data errors. This is
-	  useful to test the error handling in the mmc block device
-	  and to test how the mmc host driver handles retries from
-	  the block device.
-
 config FAIL_FUTEX
 	bool "Fault-injection capability for futexes"
 	select DEBUG_FS
@@ -1561,6 +1551,12 @@ config FAIL_FUTEX
 	help
 	  Provide fault-injection capability for futexes.
 
+config FAULT_INJECTION_DEBUG_FS
+	bool "Debugfs entries for fault-injection capabilities"
+	depends on FAULT_INJECTION && SYSFS && DEBUG_FS
+	help
+	  Enable configuration of fault-injection capabilities via debugfs.
+
 config FAIL_FUNCTION
 	bool "Fault-injection capability for functions"
 	depends on FAULT_INJECTION_DEBUG_FS && FUNCTION_ERROR_INJECTION
@@ -1571,11 +1567,15 @@ config FAIL_FUNCTION
 	  an error value and have to handle it. This is useful to test the
 	  error handling in various subsystems.
 
-config FAULT_INJECTION_DEBUG_FS
-	bool "Debugfs entries for fault-injection capabilities"
-	depends on FAULT_INJECTION && SYSFS && DEBUG_FS
+config FAIL_MMC_REQUEST
+	bool "Fault-injection capability for MMC IO"
+	depends on FAULT_INJECTION_DEBUG_FS && MMC
 	help
-	  Enable configuration of fault-injection capabilities via debugfs.
+	  Provide fault-injection capability for MMC IO.
+	  This will make the mmc core return data errors. This is
+	  useful to test the error handling in the mmc block device
+	  and to test how the mmc host driver handles retries from
+	  the block device.
 
 config FAULT_INJECTION_STACKTRACE_FILTER
 	bool "stacktrace filter for fault-injection capabilities"
