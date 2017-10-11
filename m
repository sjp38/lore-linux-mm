Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f200.google.com (mail-pf0-f200.google.com [209.85.192.200])
	by kanga.kvack.org (Postfix) with ESMTP id 1D94A6B0253
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:24:49 -0400 (EDT)
Received: by mail-pf0-f200.google.com with SMTP id j64so3199723pfj.6
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:24:49 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id q13si1314358pgc.232.2017.10.11.01.24.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 01:24:48 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 11/11] Add KASan layout
Date: Wed, 11 Oct 2017 16:22:27 +0800
Message-ID: <20171011082227.20546-12-liuwenliang@huawei.com>
In-Reply-To: <20171011082227.20546-1-liuwenliang@huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, liuwenliang@huawei.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

Add KASan layout into virtual kernel memory layout.

Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
---
 arch/arm/mm/init.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/arch/arm/mm/init.c b/arch/arm/mm/init.c
index ad80548..b490cf4 100644
--- a/arch/arm/mm/init.c
+++ b/arch/arm/mm/init.c
@@ -537,6 +537,9 @@ void __init mem_init(void)
 #ifdef CONFIG_MODULES
 			"    modules : 0x%08lx - 0x%08lx   (%4ld MB)\n"
 #endif
+#ifdef CONFIG_KASAN
+			"    kasan   : 0x%08lx - 0x%08lx   (%4ld MB)\n"
+#endif
 			"      .text : 0x%p" " - 0x%p" "   (%4td kB)\n"
 			"      .init : 0x%p" " - 0x%p" "   (%4td kB)\n"
 			"      .data : 0x%p" " - 0x%p" "   (%4td kB)\n"
@@ -557,6 +560,9 @@ void __init mem_init(void)
 #ifdef CONFIG_MODULES
 			MLM(MODULES_VADDR, MODULES_END),
 #endif
+#ifdef CONFIG_KASAN
+			MLM(KASAN_SHADOW_START, KASAN_SHADOW_END),
+#endif
 
 			MLK_ROUNDUP(_text, _etext),
 			MLK_ROUNDUP(__init_begin, __init_end),
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
