Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vk0-f53.google.com (mail-vk0-f53.google.com [209.85.213.53])
	by kanga.kvack.org (Postfix) with ESMTP id 0CD9C6B0038
	for <linux-mm@kvack.org>; Tue, 17 Nov 2015 06:48:41 -0500 (EST)
Received: by vkas68 with SMTP id s68so3468310vka.2
        for <linux-mm@kvack.org>; Tue, 17 Nov 2015 03:48:40 -0800 (PST)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTPS id w128si2342480vkd.59.2015.11.17.03.48.40
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 17 Nov 2015 03:48:40 -0800 (PST)
Subject: [PATCH] fault-inject: correct printk order for interval vs.
 probability
From: Jesper Dangaard Brouer <brouer@redhat.com>
Date: Tue, 17 Nov 2015 12:48:37 +0100
Message-ID: <20151117114750.12395.53387.stgit@firesoul>
MIME-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akinobu.mita@gmail.com, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, dmonakhov@openvz.org, Jesper Dangaard Brouer <brouer@redhat.com>

In function fail_dump() printk output of the attributes interval and
probability got swapped.  This was introduced in commit
6adc4a22f20b ("fault-inject: add ratelimit option").

Fixes: 6adc4a22f20b ("fault-inject: add ratelimit option")
Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>

---
Don't know who is maintainer for lib/, hope someone will
pick this up...

 lib/fault-inject.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/lib/fault-inject.c b/lib/fault-inject.c
index f1cdeb024d17..6a823a53e357 100644
--- a/lib/fault-inject.c
+++ b/lib/fault-inject.c
@@ -44,7 +44,7 @@ static void fail_dump(struct fault_attr *attr)
 		printk(KERN_NOTICE "FAULT_INJECTION: forcing a failure.\n"
 		       "name %pd, interval %lu, probability %lu, "
 		       "space %d, times %d\n", attr->dname,
-		       attr->probability, attr->interval,
+		       attr->interval, attr->probability,
 		       atomic_read(&attr->space),
 		       atomic_read(&attr->times));
 		if (attr->verbose > 1)

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
