Return-Path: <SRS0=RO59=RR=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-8.8 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,FREEMAIL_FORGED_FROMDOMAIN,FREEMAIL_FROM,
	HEADER_FROM_DIFFERENT_DOMAINS,INCLUDES_PATCH,MAILING_LIST_MULTI,SIGNED_OFF_BY,
	SPF_PASS,URIBL_BLOCKED,USER_AGENT_GIT autolearn=unavailable
	autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 684B1C10F06
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:06:52 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id 2665E2063F
	for <linux-mm@archiver.kernel.org>; Thu, 14 Mar 2019 11:06:52 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=gmail.com header.i=@gmail.com header.b="qg0Upq0j"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org 2665E2063F
Authentication-Results: mail.kernel.org; dmarc=fail (p=none dis=none) header.from=gmail.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id B01478E0003; Thu, 14 Mar 2019 07:06:51 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id AB0448E0001; Thu, 14 Mar 2019 07:06:51 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 9521B8E0003; Thu, 14 Mar 2019 07:06:51 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-pf1-f199.google.com (mail-pf1-f199.google.com [209.85.210.199])
	by kanga.kvack.org (Postfix) with ESMTP id 5481C8E0001
	for <linux-mm@kvack.org>; Thu, 14 Mar 2019 07:06:51 -0400 (EDT)
Received: by mail-pf1-f199.google.com with SMTP id w16so5831507pfn.3
        for <linux-mm@kvack.org>; Thu, 14 Mar 2019 04:06:51 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:from:to:subject:date:message-id;
        bh=dDpta30jYLNKF7mHLIZXQMhcyv7dkmDy6qiilMUlgNY=;
        b=sXQ9JBZiYL4oZXH3+wPIYkEBKzxT4CYnRu+5ojt0+Z4qRg7XlY4EuIOPQ9z1EuGI2c
         YjMIOB6k2lW8gyjP016deiznX2sxGRT0YlNp6M+Rkxuji4fcI8BnvCpbHQXhfOho0hMp
         oWV8zMfcJ0gT3/XcYxPVCYT/hVhESqW2ks6Uipx0qGqjENF93SMF2hk/rpkZjpKKzvfj
         DFWMML9Tm1bppuZfZivqTZCPeWT4gwY5zUoSVcabeW96977N0VLBD2uUl+8GAGA7LPwm
         3tN2bbN5Dqs7FlYuGE6FBeWW8IPosxgBp9ndxxxve8nBML3RLQ0ukhM+mHPo28gB8O7d
         R3Sw==
X-Gm-Message-State: APjAAAUfRawA0tpsPFpjF8dG8hvLs2300NTdc5DAmnibyG1HjNOSocJm
	tdrnM3xft1rlZF9MIxC7fcnHH/kt6sOiziDEbL6y4kLI6z+vtmiPCcDkmrCVaXh4h3Lm0f0lmXx
	+GPk2rJ1H3Hdjzmh7qDLn2aAerDDqa3KLhxM3MOwxN8tZaL7o348kUbak5vy6Brqu/3wyrL2rDZ
	MvLxcN4LCf1WqvXg5SKQeGRnXL6FQJTHo9YSAZ7M50SoN08p3ko+yh44c/QuF36WuJxjPJn+oNv
	8HzqWT8jcwoyyq6jPZkA+OKu5eRmKE31RvQrLBOjNdkLJkM2/kfIEgP8Ghdb4cHQkmwwzgn9wJ/
	bvDa1bu6/Yfv4wk1avpETaUgqNHq35NNeTIfse9Z8RDCjQGd+A4a73kupBQUg+gQ8ev6EEcZonF
	M
X-Received: by 2002:a62:9419:: with SMTP id m25mr139842pfe.68.1552561610946;
        Thu, 14 Mar 2019 04:06:50 -0700 (PDT)
X-Received: by 2002:a62:9419:: with SMTP id m25mr139617pfe.68.1552561608125;
        Thu, 14 Mar 2019 04:06:48 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1552561608; cv=none;
        d=google.com; s=arc-20160816;
        b=yY8BdhXsTQnA4olHmzTKGNouG0eY60f9CxOb2zv5QQ1A5HYznBCBB6Q1apTlhawSqt
         95oL+0KVKuxC7x1Sib9n6l0LfFZBIo7kHIpTWv4raJMRcf955jMtbXhM2jUFLpPg/ylS
         /XWvv3lZBZ+m7o2NYmE6DPxXDGKqlCeI+bwY+c0YzeGWMR/LrDP+HgLyOWo3n9BMVgm4
         N3HQ7VlVCtxt8fmnMPnqU/PZkyLe1xPMoPaV8xtgnWlaF+Wr9TzB0rkNd1MspTdjux11
         UHBubKt9jo871+pgHIV5+E62PROLSj0CxrO1ZJ37ihWf7T0dKfmjo/nmUUSUOtRi+o9t
         7bEg==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=message-id:date:subject:to:from:dkim-signature;
        bh=dDpta30jYLNKF7mHLIZXQMhcyv7dkmDy6qiilMUlgNY=;
        b=07Uqq7+TFi+f7ppu3NdBoM8JItVuIfAbQ9KzudnsofDsq2ZeVC38xSjrLcbjsVIXS6
         V85UhGWDd+rsiQ3RpD6R6RWlGtTkUrguGRWhiOJv/OZA+FeoJaPbackN3BKd+U9oV1xK
         APSYXokZnNpFVb/KrCJcfT5RpcmOUF7qcyWeuabz+mWU5kFoxdJsays+bj/SLs6LDtGq
         Uat8taEJf2nO+E6TdnavxO2KVInMt5MFDJxpFl8FjbLs5AhQ0MlGjqyfUriw/Orvjt1S
         21XIkjiaJe0pnuiV/nigcerMZceWwCtaHiBjj+DCOGUNe9FfOZE8z7GjA6U1wcq6hpCH
         1v+Q==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qg0Upq0j;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id f4sor22859372pgs.80.2019.03.14.04.06.48
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 14 Mar 2019 04:06:48 -0700 (PDT)
Received-SPF: pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@gmail.com header.s=20161025 header.b=qg0Upq0j;
       spf=pass (google.com: domain of huangzhaoyang@gmail.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=huangzhaoyang@gmail.com;
       dmarc=pass (p=NONE sp=QUARANTINE dis=NONE) header.from=gmail.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=gmail.com; s=20161025;
        h=from:to:subject:date:message-id;
        bh=dDpta30jYLNKF7mHLIZXQMhcyv7dkmDy6qiilMUlgNY=;
        b=qg0Upq0jLvULMOwFu0QqrcExCbpgeGAFck4cpAGMfSMae4olbUVvqFGX5H6rszL0GD
         Eazcbr7+WWVwiMyzT4KGFo6wy/qGb0u9hRkoQ8AHdtafW5yAo5C3pBPvPdQM6kvECJrp
         ihbUYEWyUyWywmlbPwPcbWFv134JPlxjhB6sdEW1QRKxESzUuIiPkdoaf1yJEdKjgdo7
         nHqcLC+biYyG7xdFsW2DiApSE8lFh/Lzk3+H8EENXT4Xp3PKSWwAzHv3fTOw9effgiKV
         jEoPbz7kXu0+19S+GVOO0SugxanKeeF4putCQGQLQwZ04L4kHYnaEt+8rut9NQEFNKQ3
         oslQ==
X-Google-Smtp-Source: APXvYqy4RS+bxR506y0XuvByBPnIl58NXLP8IhUhzOa/Zpg3bff6IB+yfFHI8pYokkVNxk/1Z81FKw==
X-Received: by 2002:a65:4549:: with SMTP id x9mr45326928pgr.3.1552561607767;
        Thu, 14 Mar 2019 04:06:47 -0700 (PDT)
Received: from bj03382pcu.spreadtrum.com ([117.18.48.82])
        by smtp.gmail.com with ESMTPSA id g12sm14364692pfd.72.2019.03.14.04.06.44
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 14 Mar 2019 04:06:47 -0700 (PDT)
From: Zhaoyang Huang <huangzhaoyang@gmail.com>
To: Chintan Pandya <cpandya@codeaurora.org>,
	David Rientjes <rientjes@google.com>,
	Joe Perches <joe@perches.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Michal Hocko <mhocko@suse.com>,
	linux-mm@kvack.org,
	linux-kernel@vger.kernel.org
Subject: [PATCH] driver : staging : ion: optimization for decreasing memory fragmentaion
Date: Thu, 14 Mar 2019 19:06:39 +0800
Message-Id: <1552561599-23662-1-git-send-email-huangzhaoyang@gmail.com>
X-Mailer: git-send-email 1.7.9.5
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

From: Zhaoyang Huang <zhaoyang.huang@unisoc.com>

Two action for this patch:
1. set a batch size for system heap's shrinker, which can have it buffer
reasonable page blocks in pool for future allocation.
2. reverse the order sequence when free page blocks, the purpose is also
to have system heap keep as more big blocks as it can.

By testing on an android system with 2G RAM, the changes with setting
batch = 48MB can help reduce the fragmentation obviously and improve
big block allocation speed for 15%.

Signed-off-by: Zhaoyang Huang <zhaoyang.huang@unisoc.com>
---
 drivers/staging/android/ion/ion_heap.c        | 12 +++++++++++-
 drivers/staging/android/ion/ion_system_heap.c |  2 +-
 2 files changed, 12 insertions(+), 2 deletions(-)

diff --git a/drivers/staging/android/ion/ion_heap.c b/drivers/staging/android/ion/ion_heap.c
index 31db510..9e9caf2 100644
--- a/drivers/staging/android/ion/ion_heap.c
+++ b/drivers/staging/android/ion/ion_heap.c
@@ -16,6 +16,8 @@
 #include <linux/vmalloc.h>
 #include "ion.h"
 
+unsigned long ion_heap_batch = 0;
+
 void *ion_heap_map_kernel(struct ion_heap *heap,
 			  struct ion_buffer *buffer)
 {
@@ -303,7 +305,15 @@ int ion_heap_init_shrinker(struct ion_heap *heap)
 	heap->shrinker.count_objects = ion_heap_shrink_count;
 	heap->shrinker.scan_objects = ion_heap_shrink_scan;
 	heap->shrinker.seeks = DEFAULT_SEEKS;
-	heap->shrinker.batch = 0;
+	heap->shrinker.batch = ion_heap_batch;
 
 	return register_shrinker(&heap->shrinker);
 }
+
+static int __init ion_system_heap_batch_init(char *arg)
+{
+	 ion_heap_batch = memparse(arg, NULL);
+
+	return 0;
+}
+early_param("ion_batch", ion_system_heap_batch_init);
diff --git a/drivers/staging/android/ion/ion_system_heap.c b/drivers/staging/android/ion/ion_system_heap.c
index 701eb9f..d249f8d 100644
--- a/drivers/staging/android/ion/ion_system_heap.c
+++ b/drivers/staging/android/ion/ion_system_heap.c
@@ -182,7 +182,7 @@ static int ion_system_heap_shrink(struct ion_heap *heap, gfp_t gfp_mask,
 	if (!nr_to_scan)
 		only_scan = 1;
 
-	for (i = 0; i < NUM_ORDERS; i++) {
+	for (i = NUM_ORDERS - 1; i >= 0; i--) {
 		pool = sys_heap->pools[i];
 
 		if (only_scan) {
-- 
1.9.1

