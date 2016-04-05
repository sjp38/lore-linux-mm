Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf0-f43.google.com (mail-lf0-f43.google.com [209.85.215.43])
	by kanga.kvack.org (Postfix) with ESMTP id 3D5A76B007E
	for <linux-mm@kvack.org>; Tue,  5 Apr 2016 04:29:22 -0400 (EDT)
Received: by mail-lf0-f43.google.com with SMTP id e190so3139387lfe.0
        for <linux-mm@kvack.org>; Tue, 05 Apr 2016 01:29:22 -0700 (PDT)
Received: from szxga02-in.huawei.com (szxga02-in.huawei.com. [119.145.14.65])
        by mx.google.com with ESMTPS id d13si18482682lfd.149.2016.04.05.01.29.18
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Tue, 05 Apr 2016 01:29:20 -0700 (PDT)
From: Chen Feng <puck.chen@hisilicon.com>
Subject: [PATCH 1/2] arm64: mem-model: add flatmem model for arm64
Date: Tue, 5 Apr 2016 16:22:51 +0800
Message-ID: <1459844572-53069-1-git-send-email-puck.chen@hisilicon.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: catalin.marinas@arm.com, will.deacon@arm.com, ard.biesheuvel@linaro.org, mark.rutland@arm.com, akpm@linux-foundation.org, robin.murphy@arm.com, linux-arm-kernel@lists.infradead.org, linux-kernel@vger.kernel.org, mhocko@suse.com, kirill.shutemov@linux.intel.com, rientjes@google.com, linux-mm@kvack.org
Cc: puck.chen@hisilicon.com, puck.chen@foxmail.com, oliver.fu@hisilicon.com, linuxarm@huawei.com, dan.zhao@hisilicon.com, suzhuangluan@hisilicon.com, yudongbin@hislicon.com, albert.lubing@hisilicon.com, xuyiping@hisilicon.com, saberlily.xia@hisilicon.com

We can reduce the memory allocated at mem-map
by flatmem.

currently, the default memory-model in arm64 is
sparse memory. The mem-map array is not freed in
this scene. If the physical address is too long,
it will reserved too much memory for the mem-map
array.

Signed-off-by: Chen Feng <puck.chen@hisilicon.com>
Signed-off-by: Fu Jun <oliver.fu@hisilicon.com>
---
 arch/arm64/Kconfig | 3 +++
 1 file changed, 3 insertions(+)

diff --git a/arch/arm64/Kconfig b/arch/arm64/Kconfig
index 4f43622..c18930d 100644
--- a/arch/arm64/Kconfig
+++ b/arch/arm64/Kconfig
@@ -559,6 +559,9 @@ config ARCH_SPARSEMEM_ENABLE
 	def_bool y
 	select SPARSEMEM_VMEMMAP_ENABLE
 
+config ARCH_FLATMEM_ENABLE
+	def_bool y
+
 config ARCH_SPARSEMEM_DEFAULT
 	def_bool ARCH_SPARSEMEM_ENABLE
 
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
