Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f199.google.com (mail-pf0-f199.google.com [209.85.192.199])
	by kanga.kvack.org (Postfix) with ESMTP id CB60A6B0003
	for <linux-mm@kvack.org>; Thu,  3 May 2018 16:18:11 -0400 (EDT)
Received: by mail-pf0-f199.google.com with SMTP id c4so15910246pfg.22
        for <linux-mm@kvack.org>; Thu, 03 May 2018 13:18:11 -0700 (PDT)
Received: from mga04.intel.com (mga04.intel.com. [192.55.52.120])
        by mx.google.com with ESMTPS id a90-v6si8550389plc.329.2018.05.03.13.18.10
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 03 May 2018 13:18:10 -0700 (PDT)
From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: [PATCH v1] mm, vmpressure: use kstrndup instead of kmalloc+strncpy
Date: Thu,  3 May 2018 23:18:07 +0300
Message-Id: <20180503201807.24941-1-andriy.shevchenko@linux.intel.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: David Rientjes <rientjes@google.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>
Cc: Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Using kstrndup() simplifies the code.

Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
---
 mm/vmpressure.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/vmpressure.c b/mm/vmpressure.c
index 85350ce2d25d..7142207224d3 100644
--- a/mm/vmpressure.c
+++ b/mm/vmpressure.c
@@ -390,12 +390,11 @@ int vmpressure_register_event(struct mem_cgroup *memcg,
 	char *token;
 	int ret = 0;
 
-	spec_orig = spec = kzalloc(MAX_VMPRESSURE_ARGS_LEN + 1, GFP_KERNEL);
+	spec_orig = spec = kstrndup(args, MAX_VMPRESSURE_ARGS_LEN, GFP_KERNEL);
 	if (!spec) {
 		ret = -ENOMEM;
 		goto out;
 	}
-	strncpy(spec, args, MAX_VMPRESSURE_ARGS_LEN);
 
 	/* Find required level */
 	token = strsep(&spec, ",");
-- 
2.17.0
