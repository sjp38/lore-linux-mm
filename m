Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f197.google.com (mail-pf0-f197.google.com [209.85.192.197])
	by kanga.kvack.org (Postfix) with ESMTP id DC36A828E1
	for <linux-mm@kvack.org>; Tue,  2 Aug 2016 08:52:25 -0400 (EDT)
Received: by mail-pf0-f197.google.com with SMTP id o124so333024911pfg.1
        for <linux-mm@kvack.org>; Tue, 02 Aug 2016 05:52:25 -0700 (PDT)
Received: from mga03.intel.com (mga03.intel.com. [134.134.136.65])
        by mx.google.com with ESMTP id i5si3021859pae.80.2016.08.02.05.52.25
        for <linux-mm@kvack.org>;
        Tue, 02 Aug 2016 05:52:25 -0700 (PDT)
From: Baole Ni <baolex.ni@intel.com>
Subject: [PATCH 1081/1285] Replace numeric parameter like 0444 with macro
Date: Tue,  2 Aug 2016 20:14:43 +0800
Message-Id: <20160802121443.22191-1-baolex.ni@intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: jbaron@akamai.com, jiangshanlai@gmail.com, rostedt@goodmis.org, mathieu.desnoyers@efficios.com, m.chehab@samsung.com, gregkh@linuxfoundation.org, m.szyprowski@samsung.com, kyungmin.park@samsung.com, k.kozlowski@samsung.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org, akpm@linux-foundation.org, kirill.shutemov@linux.intel.com, oleg@redhat.com, gang.chen.5i5j@gmail.com, mhocko@suse.com, koct9i@gmail.com, aarcange@redhat.com, aryabinin@virtuozzo.com, chuansheng.liu@intel.com, baolex.ni@intel.com

I find that the developers often just specified the numeric value
when calling a macro which is defined with a parameter for access permission.
As we know, these numeric value for access permission have had the corresponding macro,
and that using macro can improve the robustness and readability of the code,
thus, I suggest replacing the numeric parameter with the macro.

Signed-off-by: Chuansheng Liu <chuansheng.liu@intel.com>
Signed-off-by: Baole Ni <baolex.ni@intel.com>
---
 mm/mmap.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/mmap.c b/mm/mmap.c
index de2c176..fad009c 100644
--- a/mm/mmap.c
+++ b/mm/mmap.c
@@ -67,7 +67,7 @@ int mmap_rnd_compat_bits __read_mostly = CONFIG_ARCH_MMAP_RND_COMPAT_BITS;
 #endif
 
 static bool ignore_rlimit_data;
-core_param(ignore_rlimit_data, ignore_rlimit_data, bool, 0644);
+core_param(ignore_rlimit_data, ignore_rlimit_data, bool, S_IRUSR | S_IWUSR | S_IRGRP | S_IROTH);
 
 static void unmap_region(struct mm_struct *mm,
 		struct vm_area_struct *vma, struct vm_area_struct *prev,
-- 
2.9.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
