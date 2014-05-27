Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-la0-f42.google.com (mail-la0-f42.google.com [209.85.215.42])
	by kanga.kvack.org (Postfix) with ESMTP id B97356B0096
	for <linux-mm@kvack.org>; Tue, 27 May 2014 10:13:22 -0400 (EDT)
Received: by mail-la0-f42.google.com with SMTP id el20so6575254lab.15
        for <linux-mm@kvack.org>; Tue, 27 May 2014 07:13:22 -0700 (PDT)
Received: from mail-la0-x22e.google.com (mail-la0-x22e.google.com [2a00:1450:4010:c03::22e])
        by mx.google.com with ESMTPS id s2si16689939laj.14.2014.05.27.07.13.20
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Tue, 27 May 2014 07:13:21 -0700 (PDT)
Received: by mail-la0-f46.google.com with SMTP id ec20so4965981lab.19
        for <linux-mm@kvack.org>; Tue, 27 May 2014 07:13:20 -0700 (PDT)
Subject: [PATCH] mm/process_vm_access: move config option into init/Kconfig
From: Konstantin Khlebnikov <koct9i@gmail.com>
Date: Tue, 27 May 2014 18:13:13 +0400
Message-ID: <20140527141313.23853.29306.stgit@zurg>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: Davidlohr Bueso <davidlohr@hp.com>, Hugh Dickins <hughd@google.com>, Al Viro <viro@zeniv.linux.org.uk>

CONFIG_CROSS_MEMORY_ATTACH adds couple syscalls: process_vm_readv and
process_vm_writev, it's a kind of IPC for copying data between processes.
Currently this option is placed inside "Processor type and features".

This patch moves it into "General setup" (where all other arch-independed
syscalls and ipc features are placed) and changes prompt string to less cryptic.

Signed-off-by: Konstantin Khlebnikov <koct9i@gmail.com>
---
 init/Kconfig |   10 ++++++++++
 mm/Kconfig   |   10 ----------
 2 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/init/Kconfig b/init/Kconfig
index 9d3585b..d6ddb7a 100644
--- a/init/Kconfig
+++ b/init/Kconfig
@@ -261,6 +261,16 @@ config POSIX_MQUEUE_SYSCTL
 	depends on SYSCTL
 	default y
 
+config CROSS_MEMORY_ATTACH
+	bool "Enable process_vm_readv/writev syscalls"
+	depends on MMU
+	default y
+	help
+	  Enabling this option adds the system calls process_vm_readv and
+	  process_vm_writev which allow a process with the correct privileges
+	  to directly read from or write to to another process's address space.
+	  See the man page for more details.
+
 config FHANDLE
 	bool "open by fhandle syscalls"
 	select EXPORTFS
diff --git a/mm/Kconfig b/mm/Kconfig
index 1b5a95f..2ec35d7 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -430,16 +430,6 @@ choice
 	  benefit.
 endchoice
 
-config CROSS_MEMORY_ATTACH
-	bool "Cross Memory Support"
-	depends on MMU
-	default y
-	help
-	  Enabling this option adds the system calls process_vm_readv and
-	  process_vm_writev which allow a process with the correct privileges
-	  to directly read from or write to to another process's address space.
-	  See the man page for more details.
-
 #
 # UP and nommu archs use km based percpu allocator
 #

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
