Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lj1-f199.google.com (mail-lj1-f199.google.com [209.85.208.199])
	by kanga.kvack.org (Postfix) with ESMTP id 1822C6B589F
	for <linux-mm@kvack.org>; Fri, 31 Aug 2018 15:44:35 -0400 (EDT)
Received: by mail-lj1-f199.google.com with SMTP id q13-v6so2262444ljj.4
        for <linux-mm@kvack.org>; Fri, 31 Aug 2018 12:44:35 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id i11-v6sor3502055lfb.56.2018.08.31.12.44.33
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 31 Aug 2018 12:44:33 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [PATCH] mm: percpu: remove unnecessary unlikely()
Date: Fri, 31 Aug 2018 22:44:22 +0300
Message-Id: <20180831194422.13730-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dennis Zhou <dennisszhou@gmail.com>
Cc: igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>, Tejun Heo <tj@kernel.org>, zijun_hu <zijun_hu@htc.com>, Christoph Lameter <cl@linux.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

WARN_ON() already contains an unlikely(), so it's not necessary to
wrap it into another.

Signed-off-by: Igor Stoppa <igor.stoppa@huawei.com>
Acked-by: Dennis Zhou <dennisszhou@gmail.com>
Cc: Tejun Heo <tj@kernel.org>
Cc: zijun_hu <zijun_hu@htc.com>
Cc: Christoph Lameter <cl@linux.com>
Cc: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org
---
 mm/percpu.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/percpu.c b/mm/percpu.c
index a749d4d96e3e..f5c2796fe63e 100644
--- a/mm/percpu.c
+++ b/mm/percpu.c
@@ -2588,7 +2588,7 @@ int __init pcpu_page_first_chunk(size_t reserved_size,
 	BUG_ON(ai->nr_groups != 1);
 	upa = ai->alloc_size/ai->unit_size;
 	nr_g0_units = roundup(num_possible_cpus(), upa);
-	if (unlikely(WARN_ON(ai->groups[0].nr_units != nr_g0_units))) {
+	if (WARN_ON(ai->groups[0].nr_units != nr_g0_units)) {
 		pcpu_free_alloc_info(ai);
 		return -EINVAL;
 	}
-- 
2.17.1
