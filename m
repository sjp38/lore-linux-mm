Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-lf1-f71.google.com (mail-lf1-f71.google.com [209.85.167.71])
	by kanga.kvack.org (Postfix) with ESMTP id C9D8C6B7FAD
	for <linux-mm@kvack.org>; Fri,  7 Sep 2018 14:10:48 -0400 (EDT)
Received: by mail-lf1-f71.google.com with SMTP id o22-v6so2882853lfk.5
        for <linux-mm@kvack.org>; Fri, 07 Sep 2018 11:10:48 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id v18-v6sor4672920ljj.31.2018.09.07.11.10.46
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 07 Sep 2018 11:10:46 -0700 (PDT)
From: Igor Stoppa <igor.stoppa@gmail.com>
Subject: [RESEND PATCH] mm: percpu: remove unnecessary unlikely()
Date: Fri,  7 Sep 2018 21:10:35 +0300
Message-Id: <20180907181035.1662-1-igor.stoppa@huawei.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Tejun Heo <tj@kernel.org>, Christoph Lameter <cl@linux.com>, Dennis Zhou <dennisszhou@gmail.com>
Cc: igor.stoppa@gmail.com, Igor Stoppa <igor.stoppa@huawei.com>, zijun_hu <zijun_hu@htc.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

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
