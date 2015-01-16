Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qa0-f49.google.com (mail-qa0-f49.google.com [209.85.216.49])
	by kanga.kvack.org (Postfix) with ESMTP id F33636B0032
	for <linux-mm@kvack.org>; Fri, 16 Jan 2015 09:17:21 -0500 (EST)
Received: by mail-qa0-f49.google.com with SMTP id v8so15525916qal.8
        for <linux-mm@kvack.org>; Fri, 16 Jan 2015 06:17:21 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id a1si6029111qar.108.2015.01.16.06.17.20
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 16 Jan 2015 06:17:21 -0800 (PST)
From: Rafael Aquini <aquini@redhat.com>
Subject: [PATCH 2/2] fs: proc: task_mmu: bump kernelpagesize_kB to EOL in /proc/pid/numa_maps
Date: Fri, 16 Jan 2015 08:50:51 -0500
Message-Id: <7baa6d6c187310cd44db0fab6c3029af80de3543.1421415776.git.aquini@redhat.com>
In-Reply-To: <cover.1421415776.git.aquini@redhat.com>
References: <cover.1421415776.git.aquini@redhat.com>
In-Reply-To: <cover.1421415776.git.aquini@redhat.com>
References: <cover.1421415776.git.aquini@redhat.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: akpm@linux-foundation.org, jweiner@redhat.com, dave.hansen@linux.intel.com, rientjes@google.com, linux-mm@kvack.org

Commit "4dd025c fs: proc: task_mmu: show page size in /proc/<pid>/numa_maps"
(linux-next) introduces 'kernelpagesize_kB' to numa_maps proc interface.
This patch, per Andrew Morton suggestion, switchs 'kernelpagesize_kB' position
to EOL in /proc/<pid>/numa_maps to potentially avoid causing trouble to any
existent parser that expects numa_maps file line previous layout.

Signed-off-by: Rafael Aquini <aquini@redhat.com>
---
 Documentation/filesystems/proc.txt | 30 +++++++++++++++---------------
 fs/proc/task_mmu.c                 |  4 ++--
 2 files changed, 17 insertions(+), 17 deletions(-)

diff --git a/Documentation/filesystems/proc.txt b/Documentation/filesystems/proc.txt
index 0be178f..a1123c1 100644
--- a/Documentation/filesystems/proc.txt
+++ b/Documentation/filesystems/proc.txt
@@ -507,22 +507,22 @@ summarized separated by blank spaces, one mapping per each file line:
 
 address   policy    mapping details
 
-00400000 default file=/usr/local/bin/app kernelpagesize_kB=4 mapped=1 active=0 N3=1
-00600000 default file=/usr/local/bin/app kernelpagesize_kB=4 anon=1 dirty=1 N3=1
-3206000000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 mapped=26 mapmax=6 N0=24 N3=2
-320621f000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
-3206220000 default file=/lib64/ld-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
-3206221000 default kernelpagesize_kB=4 anon=1 dirty=1 N3=1
-3206800000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 mapped=59 mapmax=21 active=55 N0=41 N3=18
+00400000 default file=/usr/local/bin/app mapped=1 active=0 N3=1 kernelpagesize_kB=4
+00600000 default file=/usr/local/bin/app anon=1 dirty=1 N3=1 kernelpagesize_kB=4
+3206000000 default file=/lib64/ld-2.12.so mapped=26 mapmax=6 N0=24 N3=2 kernelpagesize_kB=4
+320621f000 default file=/lib64/ld-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
+3206220000 default file=/lib64/ld-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
+3206221000 default anon=1 dirty=1 N3=1 kernelpagesize_kB=4
+3206800000 default file=/lib64/libc-2.12.so mapped=59 mapmax=21 active=55 N0=41 N3=18 kernelpagesize_kB=4
 320698b000 default file=/lib64/libc-2.12.so
-3206b8a000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 anon=2 dirty=2 N3=2
-3206b8e000 default file=/lib64/libc-2.12.so kernelpagesize_kB=4 anon=1 dirty=1 N3=1
-3206b8f000 default kernelpagesize_kB=4 anon=3 dirty=3 active=1 N3=3
-7f4dc10a2000 default kernelpagesize_kB=4 anon=3 dirty=3 N3=3
-7f4dc10b4000 default kernelpagesize_kB=4 anon=2 dirty=2 active=1 N3=2
-7f4dc1200000 default file=/anon_hugepage\040(deleted) huge kernelpagesize_kB=2048 anon=1 dirty=1 N3=1
-7fff335f0000 default stack kernelpagesize_kB=4 anon=3 dirty=3 N3=3
-7fff3369d000 default kernelpagesize_kB=4 mapped=1 mapmax=35 active=0 N3=1
+3206b8a000 default file=/lib64/libc-2.12.so anon=2 dirty=2 N3=2 kernelpagesize_kB=4
+3206b8e000 default file=/lib64/libc-2.12.so anon=1 dirty=1 N3=1 kernelpagesize_kB=4
+3206b8f000 default anon=3 dirty=3 active=1 N3=3 kernelpagesize_kB=4
+7f4dc10a2000 default anon=3 dirty=3 N3=3 kernelpagesize_kB=4
+7f4dc10b4000 default anon=2 dirty=2 active=1 N3=2 kernelpagesize_kB=4
+7f4dc1200000 default file=/anon_hugepage\040(deleted) huge anon=1 dirty=1 N3=1 kernelpagesize_kB=2048
+7fff335f0000 default stack anon=3 dirty=3 N3=3 kernelpagesize_kB=4
+7fff3369d000 default mapped=1 mapmax=35 active=0 N3=1 kernelpagesize_kB=4
 
 Where:
 "address" is the starting address for the mapping;
diff --git a/fs/proc/task_mmu.c b/fs/proc/task_mmu.c
index 8faae6f..f896286 100644
--- a/fs/proc/task_mmu.c
+++ b/fs/proc/task_mmu.c
@@ -1531,8 +1531,6 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	if (!md->pages)
 		goto out;
 
-	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
-
 	if (md->anon)
 		seq_printf(m, " anon=%lu", md->anon);
 
@@ -1557,6 +1555,8 @@ static int show_numa_map(struct seq_file *m, void *v, int is_pid)
 	for_each_node_state(nid, N_MEMORY)
 		if (md->node[nid])
 			seq_printf(m, " N%d=%lu", nid, md->node[nid]);
+
+	seq_printf(m, " kernelpagesize_kB=%lu", vma_kernel_pagesize(vma) >> 10);
 out:
 	seq_putc(m, '\n');
 	m_cache_vma(m, vma);
-- 
1.9.3

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
