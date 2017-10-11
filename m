Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f71.google.com (mail-pg0-f71.google.com [74.125.83.71])
	by kanga.kvack.org (Postfix) with ESMTP id C45756B0270
	for <linux-mm@kvack.org>; Wed, 11 Oct 2017 04:24:49 -0400 (EDT)
Received: by mail-pg0-f71.google.com with SMTP id u23so2822787pgo.7
        for <linux-mm@kvack.org>; Wed, 11 Oct 2017 01:24:49 -0700 (PDT)
Received: from szxga05-in.huawei.com (szxga05-in.huawei.com. [45.249.212.191])
        by mx.google.com with ESMTPS id a26si9957408pgn.797.2017.10.11.01.24.47
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Wed, 11 Oct 2017 01:24:48 -0700 (PDT)
From: Abbott Liu <liuwenliang@huawei.com>
Subject: [PATCH 03/11] arm: Kconfig: enable KASan
Date: Wed, 11 Oct 2017 16:22:19 +0800
Message-ID: <20171011082227.20546-4-liuwenliang@huawei.com>
In-Reply-To: <20171011082227.20546-1-liuwenliang@huawei.com>
References: <20171011082227.20546-1-liuwenliang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux@armlinux.org.uk, aryabinin@virtuozzo.com, liuwenliang@huawei.com, afzal.mohd.ma@gmail.com, f.fainelli@gmail.com, labbott@redhat.com, kirill.shutemov@linux.intel.com, mhocko@suse.com, cdall@linaro.org, marc.zyngier@arm.com, catalin.marinas@arm.com, akpm@linux-foundation.org, mawilcox@microsoft.com, tglx@linutronix.de, thgarnie@google.com, keescook@chromium.org, arnd@arndb.de, vladimir.murzin@arm.com, tixy@linaro.org, ard.biesheuvel@linaro.org, robin.murphy@arm.com, mingo@kernel.org, grygorii.strashko@linaro.org
Cc: glider@google.com, dvyukov@google.com, opendmb@gmail.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, kasan-dev@googlegroups.com, linux-mm@kvack.org, jiazhenghua@huawei.com, dylix.dailei@huawei.com, zengweilin@huawei.com, heshaoliang@huawei.com

From: Andrey Ryabinin <a.ryabinin@samsung.com>

This patch enable kernel address sanitizer for arm.

Cc: Andrey Ryabinin <a.ryabinin@samsung.com>
Signed-off-by: Abbott Liu <liuwenliang@huawei.com>
---
 arch/arm/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/arch/arm/Kconfig b/arch/arm/Kconfig
index 7888c98..e9249fd 100644
--- a/arch/arm/Kconfig
+++ b/arch/arm/Kconfig
@@ -46,6 +46,7 @@ config ARM
 	select HAVE_ARCH_BITREVERSE if (CPU_32v7M || CPU_32v7) && !CPU_32v6
 	select HAVE_ARCH_JUMP_LABEL if !XIP_KERNEL && !CPU_ENDIAN_BE32 && MMU
 	select HAVE_ARCH_KGDB if !CPU_ENDIAN_BE32 && MMU
+	select HAVE_ARCH_KASAN if MMU
 	select HAVE_ARCH_MMAP_RND_BITS if MMU
 	select HAVE_ARCH_SECCOMP_FILTER if (AEABI && !OABI_COMPAT)
 	select HAVE_ARCH_TRACEHOOK
-- 
2.9.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
