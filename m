Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f46.google.com (mail-oi0-f46.google.com [209.85.218.46])
	by kanga.kvack.org (Postfix) with ESMTP id 1963E6B014D
	for <linux-mm@kvack.org>; Wed, 20 May 2015 23:50:28 -0400 (EDT)
Received: by oiko83 with SMTP id o83so51644678oik.1
        for <linux-mm@kvack.org>; Wed, 20 May 2015 20:50:27 -0700 (PDT)
Received: from szxga01-in.huawei.com (szxga01-in.huawei.com. [58.251.152.64])
        by mx.google.com with ESMTPS id i67si11913637oid.10.2015.05.20.20.50.22
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Wed, 20 May 2015 20:50:23 -0700 (PDT)
From: Xie XiuQi <xiexiuqi@huawei.com>
Subject: [PATCH v6 4/5] tracing: fix build error in mm/memory-failure.c
Date: Thu, 21 May 2015 11:41:24 +0800
Message-ID: <1432179685-11369-5-git-send-email-xiexiuqi@huawei.com>
In-Reply-To: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
References: <1432179685-11369-1-git-send-email-xiexiuqi@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, n-horiguchi@ah.jp.nec.com
Cc: rostedt@goodmis.org, gong.chen@linux.intel.com, mingo@redhat.com, bp@suse.de, tony.luck@intel.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, jingle.chen@huawei.com, sfr@canb.auug.org.au, rdunlap@infradead.org, jim.epost@gmail.com

next-20150515 fails to build on i386 with the following error:

mm/built-in.o: In function `action_result':
memory-failure.c:(.text+0x344a5): undefined reference to `__tracepoint_memory_failure_event'
memory-failure.c:(.text+0x344d5): undefined reference to `__tracepoint_memory_failure_event'
memory-failure.c:(.text+0x3450c): undefined reference to `__tracepoint_memory_failure_event'

trace_memory_failure_event depends on CONFIG_RAS,
so add 'select RAS' in mm/Kconfig to avoid this error.

Reported-by: Randy Dunlap <rdunlap@infradead.org>
Reported-by: Jim Davis <jim.epost@gmail.com>
Cc: Steven Rostedt <rostedt@goodmis.org>
Cc: Chen Gong <gong.chen@linux.intel.com>
Acked-by: Naoya Horiguchi <n-horiguchi@ah.jp.nec.com>
Signed-off-by: Xie XiuQi <xiexiuqi@huawei.com>
---
 mm/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/mm/Kconfig b/mm/Kconfig
index 390214d..c180af8 100644
--- a/mm/Kconfig
+++ b/mm/Kconfig
@@ -368,6 +368,7 @@ config MEMORY_FAILURE
 	depends on ARCH_SUPPORTS_MEMORY_FAILURE
 	bool "Enable recovery from hardware memory errors"
 	select MEMORY_ISOLATION
+	select RAS
 	help
 	  Enables code to recover from some memory failures on systems
 	  with MCA recovery. This allows a system to continue running
-- 
1.7.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
