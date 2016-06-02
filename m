Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 376826B0253
	for <linux-mm@kvack.org>; Thu,  2 Jun 2016 02:15:53 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id s73so39299575pfs.0
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:53 -0700 (PDT)
Received: from mail-pf0-x243.google.com (mail-pf0-x243.google.com. [2607:f8b0:400e:c00::243])
        by mx.google.com with ESMTPS id m132si45804556pfc.122.2016.06.01.23.15.52
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 01 Jun 2016 23:15:52 -0700 (PDT)
Received: by mail-pf0-x243.google.com with SMTP id f144so6784405pfa.2
        for <linux-mm@kvack.org>; Wed, 01 Jun 2016 23:15:52 -0700 (PDT)
From: Geliang Tang <geliangtang@gmail.com>
Subject: [PATCH 3/4] mm/vmstat: remove unused header cpumask.h
Date: Thu,  2 Jun 2016 14:15:35 +0800
Message-Id: <866efd744a89b6e16c9d3acd1a00b011adbd59af.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com>
In-Reply-To: <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
References: <7cc1b41351a96e7d67fcf4bd2a6987b71793cb27.1464847139.git.geliangtang@gmail.com> <f0fa3738403f886988141182e8e4bac7efed05c7.1464847139.git.geliangtang@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, Vlastimil Babka <vbabka@suse.cz>, Michal Hocko <mhocko@suse.com>, Christoph Lameter <cl@linux.com>, Mel Gorman <mgorman@techsingularity.net>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Hugh Dickins <hughd@google.com>
Cc: Geliang Tang <geliangtang@gmail.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org

Remove unused header cpumask.h from mm/vmstat.c.

Signed-off-by: Geliang Tang <geliangtang@gmail.com>
---
 mm/vmstat.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/mm/vmstat.c b/mm/vmstat.c
index 1b585f8..3653449 100644
--- a/mm/vmstat.c
+++ b/mm/vmstat.c
@@ -15,7 +15,6 @@
 #include <linux/module.h>
 #include <linux/slab.h>
 #include <linux/cpu.h>
-#include <linux/cpumask.h>
 #include <linux/vmstat.h>
 #include <linux/proc_fs.h>
 #include <linux/seq_file.h>
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
