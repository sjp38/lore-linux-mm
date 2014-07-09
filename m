Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pa0-f50.google.com (mail-pa0-f50.google.com [209.85.220.50])
	by kanga.kvack.org (Postfix) with ESMTP id 359656B0039
	for <linux-mm@kvack.org>; Wed,  9 Jul 2014 07:36:31 -0400 (EDT)
Received: by mail-pa0-f50.google.com with SMTP id bj1so9186649pad.9
        for <linux-mm@kvack.org>; Wed, 09 Jul 2014 04:36:30 -0700 (PDT)
Received: from mailout2.w1.samsung.com (mailout2.w1.samsung.com. [210.118.77.12])
        by mx.google.com with ESMTPS id fy14si7233051pdb.120.2014.07.09.04.36.29
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-MD5 bits=128/128);
        Wed, 09 Jul 2014 04:36:29 -0700 (PDT)
Received: from eucpsbgm2.samsung.com (unknown [203.254.199.245])
 by mailout2.w1.samsung.com
 (Oracle Communications Messaging Server 7u4-24.01(7.0.4.24.0) 64bit (built Nov
 17 2011)) with ESMTP id <0N8G00CZP08BY450@mailout2.w1.samsung.com> for
 linux-mm@kvack.org; Wed, 09 Jul 2014 12:36:11 +0100 (BST)
From: Andrey Ryabinin <a.ryabinin@samsung.com>
Subject: [RFC/PATCH RESEND -next 05/21] x86: cpu: don't sanitize early stages
 of a secondary CPU boot
Date: Wed, 09 Jul 2014 15:29:59 +0400
Message-id: <1404905415-9046-6-git-send-email-a.ryabinin@samsung.com>
In-reply-to: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
References: <1404905415-9046-1-git-send-email-a.ryabinin@samsung.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Dmitry Vyukov <dvyukov@google.com>, Konstantin Serebryany <kcc@google.com>, Alexey Preobrazhensky <preobr@google.com>, Andrey Konovalov <adech.fo@gmail.com>, Yuri Gribov <tetra2005@gmail.com>, Konstantin Khlebnikov <koct9i@gmail.com>, Sasha Levin <sasha.levin@oracle.com>, Michal Marek <mmarek@suse.cz>, Russell King <linux@arm.linux.org.uk>, Thomas Gleixner <tglx@linutronix.de>, Ingo Molnar <mingo@redhat.com>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, linux-kbuild@vger.kernel.org, linux-arm-kernel@lists.infradead.org, x86@kernel.org, linux-mm@kvack.org, Andrey Ryabinin <a.ryabinin@samsung.com>

Instrumentation of this files may result in unbootable machine.

Signed-off-by: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/x86/kernel/cpu/Makefile | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/x86/kernel/cpu/Makefile b/arch/x86/kernel/cpu/Makefile
index 7fd54f0..a7bb360 100644
--- a/arch/x86/kernel/cpu/Makefile
+++ b/arch/x86/kernel/cpu/Makefile
@@ -8,6 +8,9 @@ CFLAGS_REMOVE_common.o = -pg
 CFLAGS_REMOVE_perf_event.o = -pg
 endif
 
+KASAN_SANITIZE_common.o := n
+KASAN_SANITIZE_perf_event.o := n
+
 # Make sure load_percpu_segment has no stackprotector
 nostackp := $(call cc-option, -fno-stack-protector)
 CFLAGS_common.o		:= $(nostackp)
-- 
1.8.5.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
