Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id 57B146B0253
	for <linux-mm@kvack.org>; Sat,  9 Jul 2016 04:44:52 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id a69so140612356pfa.1
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:44:52 -0700 (PDT)
Received: from mail-pa0-x244.google.com (mail-pa0-x244.google.com. [2607:f8b0:400e:c03::244])
        by mx.google.com with ESMTPS id xn7si3120812pab.53.2016.07.09.01.44.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Jul 2016 01:44:51 -0700 (PDT)
Received: by mail-pa0-x244.google.com with SMTP id ts6so9599883pac.0
        for <linux-mm@kvack.org>; Sat, 09 Jul 2016 01:44:51 -0700 (PDT)
Date: Sat, 9 Jul 2016 04:43:31 -0400
From: Janani Ravichandran <janani.rvchndrn@gmail.com>
Subject: [PATCH 1/3] Add a new field to struct shrinker
Message-ID: <85a9712f3853db5d9bc14810b287c23776235f01.1468051281.git.janani.rvchndrn@gmail.com>
References: <cover.1468051277.git.janani.rvchndrn@gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cover.1468051277.git.janani.rvchndrn@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
Cc: riel@surriel.com, akpm@linux-foundation.org, hannes@cmpxchg.org, vdavydov@virtuozzo.com, mhocko@suse.com, vbabka@suse.cz, mgorman@techsingularity.net, kirill.shutemov@linux.intel.com, bywxiaobai@163.com

Struct shrinker does not have a field to uniquely identify the shrinkers
it represents. It would be helpful to have a new field to hold names of
shrinkers. This information would be useful while analyzing their
behavior using tracepoints.

---
 include/linux/shrinker.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/shrinker.h b/include/linux/shrinker.h
index 4fcacd9..431125c 100644
--- a/include/linux/shrinker.h
+++ b/include/linux/shrinker.h
@@ -52,6 +52,7 @@ struct shrinker {
 	unsigned long (*scan_objects)(struct shrinker *,
 				      struct shrink_control *sc);
 
+	const char *name;
 	int seeks;	/* seeks to recreate an obj */
 	long batch;	/* reclaim batch size, 0 = default */
 	unsigned long flags;
-- 
2.7.0

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
