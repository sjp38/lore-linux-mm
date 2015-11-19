Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-yk0-f176.google.com (mail-yk0-f176.google.com [209.85.160.176])
	by kanga.kvack.org (Postfix) with ESMTP id 72B3C6B0255
	for <linux-mm@kvack.org>; Thu, 19 Nov 2015 13:58:22 -0500 (EST)
Received: by ykba77 with SMTP id a77so121151380ykb.2
        for <linux-mm@kvack.org>; Thu, 19 Nov 2015 10:58:22 -0800 (PST)
Received: from mx4-phx2.redhat.com (mx4-phx2.redhat.com. [209.132.183.25])
        by mx.google.com with ESMTPS id u137si2850164ywe.398.2015.11.19.10.58.21
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Thu, 19 Nov 2015 10:58:21 -0800 (PST)
Date: Thu, 19 Nov 2015 13:58:20 -0500 (EST)
From: Rodrigo Freire <rfreire@redhat.com>
Message-ID: <1281769343.11551980.1447959500824.JavaMail.zimbra@redhat.com>
In-Reply-To: <204373273.11549849.1447959061954.JavaMail.zimbra@redhat.com>
Subject: [PATCH] Documentation: Describe the shared memory usage/accounting
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel <linux-kernel@vger.kernel.org>
Cc: linux-mm@kvack.org


The Shared Memory accounting support is present in Kernel since 
commit 4b02108ac1b3 ("mm: oom analysis: add shmem vmstat") and in userland
free(1) since 2014. This patch updates the Documentation to reflect
this change.

Signed-off-by: Rodrigo Freire <rfreire@redhat.com> 
---
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -842,6 +842,7 @@
 Writeback:           0 kB
 AnonPages:      861800 kB
 Mapped:         280372 kB
+Shmem:             644 kB
 Slab:           284364 kB
 SReclaimable:   159856 kB
 SUnreclaim:     124508 kB
@@ -898,6 +899,7 @@
    AnonPages: Non-file backed pages mapped into userspace page tables
 AnonHugePages: Non-file backed huge pages mapped into userspace page tables
       Mapped: files which have been mmaped, such as libraries
+       Shmem: Total memory used by shared memory (shmem) and tmpfs
         Slab: in-kernel data structures cache
 SReclaimable: Part of Slab, that might be reclaimed, such as caches
   SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -17,10 +17,10 @@
 cannot swap and you do not have the possibility to resize them. 
 
 Since tmpfs lives completely in the page cache and on swap, all tmpfs
-pages currently in memory will show up as cached. It will not show up
-as shared or something like that. Further on you can check the actual
-RAM+swap use of a tmpfs instance with df(1) and du(1).
-
+pages will be shown in /proc/meminfo as "Shmem" and "Shared" in
+free(1). Notice that shared memory pages (see ipcs(1)) will be also
+counted as shared memory. The most reliable way to get the count is
+using df(1) and du(1).
 
 tmpfs has the following uses:
 
---
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
