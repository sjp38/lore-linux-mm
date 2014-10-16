Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f173.google.com (mail-pd0-f173.google.com [209.85.192.173])
	by kanga.kvack.org (Postfix) with ESMTP id 64AFC6B0069
	for <linux-mm@kvack.org>; Wed, 15 Oct 2014 22:19:12 -0400 (EDT)
Received: by mail-pd0-f173.google.com with SMTP id g10so2331153pdj.32
        for <linux-mm@kvack.org>; Wed, 15 Oct 2014 19:19:12 -0700 (PDT)
Received: from e23smtp03.au.ibm.com (e23smtp03.au.ibm.com. [202.81.31.145])
        by mx.google.com with ESMTPS id g5si17498622pdf.179.2014.10.15.19.19.10
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 15 Oct 2014 19:19:11 -0700 (PDT)
Received: from /spool/local
	by e23smtp03.au.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <aneesh.kumar@linux.vnet.ibm.com>;
	Thu, 16 Oct 2014 12:19:06 +1000
Received: from d23relay05.au.ibm.com (d23relay05.au.ibm.com [9.190.235.152])
	by d23dlp01.au.ibm.com (Postfix) with ESMTP id 05C4F2CE804E
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:19:05 +1100 (EST)
Received: from d23av01.au.ibm.com (d23av01.au.ibm.com [9.190.234.96])
	by d23relay05.au.ibm.com (8.14.9/8.14.9/NCO v10.0) with ESMTP id s9G1sTlU4587612
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 12:54:30 +1100
Received: from d23av01.au.ibm.com (localhost [127.0.0.1])
	by d23av01.au.ibm.com (8.14.4/8.14.4/NCO v10.0 AVout) with ESMTP id s9G2J3xj010921
	for <linux-mm@kvack.org>; Thu, 16 Oct 2014 13:19:03 +1100
From: "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>
Subject: [PATCH] mm/numa balancing: Rearrange Kconfig entry
Date: Thu, 16 Oct 2014 07:48:55 +0530
Message-Id: <1413425935-24767-1-git-send-email-aneesh.kumar@linux.vnet.ibm.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, Mel Gorman <mgorman@suse.de>
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, "Aneesh Kumar K.V" <aneesh.kumar@linux.vnet.ibm.com>

Add the default enable config option after the NUMA_BALANCING option
so that it appears related in the nconfig interface.

Signed-off-by: Aneesh Kumar K.V <aneesh.kumar@linux.vnet.ibm.com>
---
NOTE: Resending with linux-mm on cc:

 init/Kconfig | 16 ++++++++--------
 1 file changed, 8 insertions(+), 8 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 5a5613ed49bc..d73c934f9e77 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -889,14 +889,6 @@ config ARCH_SUPPORTS_INT128
 config ARCH_WANT_NUMA_VARIABLE_LOCALITY
 	bool
 
-config NUMA_BALANCING_DEFAULT_ENABLED
-	bool "Automatically enable NUMA aware memory/task placement"
-	default y
-	depends on NUMA_BALANCING
-	help
-	  If set, automatic NUMA balancing will be enabled if running on a NUMA
-	  machine.
-
 config NUMA_BALANCING
 	bool "Memory placement aware NUMA scheduler"
 	depends on ARCH_SUPPORTS_NUMA_BALANCING
@@ -909,6 +901,14 @@ config NUMA_BALANCING
 
 	  This system will be inactive on UMA systems.
 
+config NUMA_BALANCING_DEFAULT_ENABLED
+	bool "Automatically enable NUMA aware memory/task placement"
+	default y
+	depends on NUMA_BALANCING
+	help
+	  If set, automatic NUMA balancing will be enabled if running on a NUMA
+	  machine.
+
 menuconfig CGROUPS
 	boolean "Control Group support"
 	select KERNFS
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
