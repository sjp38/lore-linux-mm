Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f41.google.com (mail-qg0-f41.google.com [209.85.192.41])
	by kanga.kvack.org (Postfix) with ESMTP id 5D7AA6B0003
	for <linux-mm@kvack.org>; Mon, 21 Dec 2015 13:59:55 -0500 (EST)
Received: by mail-qg0-f41.google.com with SMTP id o11so37881257qge.2
        for <linux-mm@kvack.org>; Mon, 21 Dec 2015 10:59:55 -0800 (PST)
Received: from mx6-phx2.redhat.com (mx6-phx2.redhat.com. [209.132.183.39])
        by mx.google.com with ESMTPS id g35si30589421qgf.53.2015.12.21.10.59.54
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Mon, 21 Dec 2015 10:59:54 -0800 (PST)
Date: Mon, 21 Dec 2015 13:07:59 -0500 (EST)
From: Rodrigo Freire <rfreire@redhat.com>
Message-ID: <1612313460.962272.1450721278983.JavaMail.zimbra@redhat.com>
In-Reply-To: <5678187A.5070307@suse.cz>
References: <1281769343.11551980.1447959500824.JavaMail.zimbra@redhat.com> <5678187A.5070307@suse.cz>
Subject: [PATCH V2] Documentation: Describe the shared memory
 usage/accounting
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vlastimil Babka <vbabka@suse.cz>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, akpm@linux-foundation.org, hughd@google.com


The Shared Memory accounting support is present in Kernel since
commit 4b02108ac1b3 ("mm: oom analysis: add shmem vmstat") and in
userland free(1) since 2014. This patch updates the Documentation to
reflect this change.

Signed-off-by: Rodrigo Freire <rfreire@redhat.com>
---
V2: Better wording as per Vlastimil Babka's suggestions
---
 Documentation/filesystems/proc.txt  |    2 ++
 Documentation/filesystems/tmpfs.txt |    8 ++++----
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 402ab99..8ca61a0 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -842,6 +842,7 @@ Dirty:             968 kB
 Writeback:           0 kB
 AnonPages:      861800 kB
 Mapped:         280372 kB
+Shmem:             644 kB
 Slab:           284364 kB
 SReclaimable:   159856 kB
 SUnreclaim:     124508 kB
@@ -898,6 +899,7 @@ MemAvailable: An estimate of how much memory is available for starting new
    AnonPages: Non-file backed pages mapped into userspace page tables
 AnonHugePages: Non-file backed huge pages mapped into userspace page tables
       Mapped: files which have been mmaped, such as libraries
+       Shmem: Total memory used by shared memory (shmem) and tmpfs
         Slab: in-kernel data structures cache
 SReclaimable: Part of Slab, that might be reclaimed, such as caches
   SUnreclaim: Part of Slab, that cannot be reclaimed on memory pressure
diff --git a/Documentation/filesystems/tmpfs.txt b/Documentation/filesystems/tmpfs.txt
index 98ef551..d1abf2d 100644
--- a/Documentation/filesystems/tmpfs.txt
+++ b/Documentation/filesystems/tmpfs.txt
@@ -17,10 +17,10 @@ RAM, where you have to create an ordinary filesystem on top. Ramdisks
 cannot swap and you do not have the possibility to resize them. 
 
 Since tmpfs lives completely in the page cache and on swap, all tmpfs
-pages currently in memory will show up as cached. It will not show up
-as shared or something like that. Further on you can check the actual
-RAM+swap use of a tmpfs instance with df(1) and du(1).
-
+pages will be shown as "Shmem" in /proc/meminfo and "Shared" in
+free(1). Notice that these counters also include shared memory
+(shmem, see ipcs(1)). The most reliable way to get the count is
+using df(1) and du(1).
 
 tmpfs has the following uses:
 
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
