Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f170.google.com (mail-pf0-f170.google.com [209.85.192.170])
	by kanga.kvack.org (Postfix) with ESMTP id 5FF086B0255
	for <linux-mm@kvack.org>; Sat, 30 Jan 2016 04:31:21 -0500 (EST)
Received: by mail-pf0-f170.google.com with SMTP id n128so55130732pfn.3
        for <linux-mm@kvack.org>; Sat, 30 Jan 2016 01:31:21 -0800 (PST)
Received: from terminus.zytor.com (terminus.zytor.com. [2001:1868:205::10])
        by mx.google.com with ESMTPS id v2si28573156pfa.168.2016.01.30.01.31.20
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 30 Jan 2016 01:31:20 -0800 (PST)
Date: Sat, 30 Jan 2016 01:30:14 -0800
From: tip-bot for Toshi Kani <tipbot@zytor.com>
Message-ID: <tip-1a085d0727afaedb9506f04798516298b1676e11@git.kernel.org>
Reply-To: toshi.kani@hp.com, luto@amacapital.net, tglx@linutronix.de,
        bp@alien8.de, d.hatayama@jp.fujitsu.com, dyoung@redhat.com,
        akpm@linux-foundation.org, bhe@redhat.com, mnfhuang@gmail.com,
        linux-kernel@vger.kernel.org, mingo@kernel.org, vgoyal@redhat.com,
        torvalds@linux-foundation.org, peterz@infradead.org,
        toshi.kani@hpe.com, mcgrof@suse.com, brgerst@gmail.com,
        linux-mm@kvack.org, hpa@zytor.com, dvlasenk@redhat.com, bp@suse.de
In-Reply-To: <1453841853-11383-8-git-send-email-bp@alien8.de>
References: <1453841853-11383-8-git-send-email-bp@alien8.de>
Subject: [tip:core/resources] kexec:
  Set IORESOURCE_SYSTEM_RAM for System RAM
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Content-Type: text/plain; charset=UTF-8
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-tip-commits@vger.kernel.org
Cc: mnfhuang@gmail.com, bhe@redhat.com, akpm@linux-foundation.org, tglx@linutronix.de, toshi.kani@hp.com, luto@amacapital.net, dyoung@redhat.com, bp@alien8.de, d.hatayama@jp.fujitsu.com, dvlasenk@redhat.com, linux-mm@kvack.org, hpa@zytor.com, bp@suse.de, torvalds@linux-foundation.org, vgoyal@redhat.com, mingo@kernel.org, linux-kernel@vger.kernel.org, toshi.kani@hpe.com, mcgrof@suse.com, brgerst@gmail.com, peterz@infradead.org

Commit-ID:  1a085d0727afaedb9506f04798516298b1676e11
Gitweb:     http://git.kernel.org/tip/1a085d0727afaedb9506f04798516298b1676e11
Author:     Toshi Kani <toshi.kani@hpe.com>
AuthorDate: Tue, 26 Jan 2016 21:57:23 +0100
Committer:  Ingo Molnar <mingo@kernel.org>
CommitDate: Sat, 30 Jan 2016 09:49:57 +0100

kexec: Set IORESOURCE_SYSTEM_RAM for System RAM

Set proper ioresource flags and types for crash kernel
reservation areas.

Signed-off-by: Toshi Kani <toshi.kani@hpe.com>
Signed-off-by: Borislav Petkov <bp@suse.de>
Reviewed-by: Dave Young <dyoung@redhat.com>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Baoquan He <bhe@redhat.com>
Cc: Borislav Petkov <bp@alien8.de>
Cc: Brian Gerst <brgerst@gmail.com>
Cc: Denys Vlasenko <dvlasenk@redhat.com>
Cc: H. Peter Anvin <hpa@zytor.com>
Cc: HATAYAMA Daisuke <d.hatayama@jp.fujitsu.com>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Luis R. Rodriguez <mcgrof@suse.com>
Cc: Minfei Huang <mnfhuang@gmail.com>
Cc: Peter Zijlstra <peterz@infradead.org>
Cc: Thomas Gleixner <tglx@linutronix.de>
Cc: Toshi Kani <toshi.kani@hp.com>
Cc: Vivek Goyal <vgoyal@redhat.com>
Cc: kexec@lists.infradead.org
Cc: linux-arch@vger.kernel.org
Cc: linux-mm <linux-mm@kvack.org>
Link: http://lkml.kernel.org/r/1453841853-11383-8-git-send-email-bp@alien8.de
Signed-off-by: Ingo Molnar <mingo@kernel.org>
---
 kernel/kexec_core.c | 8 +++++---
 kernel/kexec_file.c | 2 +-
 2 files changed, 6 insertions(+), 4 deletions(-)

diff --git a/kernel/kexec_core.c b/kernel/kexec_core.c
index 8dc6591..8d34308 100644
--- a/kernel/kexec_core.c
+++ b/kernel/kexec_core.c
@@ -66,13 +66,15 @@ struct resource crashk_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 struct resource crashk_low_res = {
 	.name  = "Crash kernel",
 	.start = 0,
 	.end   = 0,
-	.flags = IORESOURCE_BUSY | IORESOURCE_MEM
+	.flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM,
+	.desc  = IORES_DESC_CRASH_KERNEL
 };
 
 int kexec_should_crash(struct task_struct *p)
@@ -959,7 +961,7 @@ int crash_shrink_memory(unsigned long new_size)
 
 	ram_res->start = end;
 	ram_res->end = crashk_res.end;
-	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_MEM;
+	ram_res->flags = IORESOURCE_BUSY | IORESOURCE_SYSTEM_RAM;
 	ram_res->name = "System RAM";
 
 	crashk_res.end = end - 1;
diff --git a/kernel/kexec_file.c b/kernel/kexec_file.c
index 007b791..2bfcdc0 100644
--- a/kernel/kexec_file.c
+++ b/kernel/kexec_file.c
@@ -525,7 +525,7 @@ int kexec_add_buffer(struct kimage *image, char *buffer, unsigned long bufsz,
 	/* Walk the RAM ranges and allocate a suitable range for the buffer */
 	if (image->type == KEXEC_TYPE_CRASH)
 		ret = walk_iomem_res("Crash kernel",
-				     IORESOURCE_MEM | IORESOURCE_BUSY,
+				     IORESOURCE_SYSTEM_RAM | IORESOURCE_BUSY,
 				     crashk_res.start, crashk_res.end, kbuf,
 				     locate_mem_hole_callback);
 	else

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
