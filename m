Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oi0-f70.google.com (mail-oi0-f70.google.com [209.85.218.70])
	by kanga.kvack.org (Postfix) with ESMTP id ED87D6B026B
	for <linux-mm@kvack.org>; Tue, 31 Oct 2017 06:39:33 -0400 (EDT)
Received: by mail-oi0-f70.google.com with SMTP id s144so18656637oih.5
        for <linux-mm@kvack.org>; Tue, 31 Oct 2017 03:39:33 -0700 (PDT)
Received: from BJEXCAS003.didichuxing.com (mx1.didichuxing.com. [111.202.154.82])
        by mx.google.com with ESMTPS id p67si743678oih.296.2017.10.31.03.39.32
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Tue, 31 Oct 2017 03:39:33 -0700 (PDT)
Date: Tue, 31 Oct 2017 18:38:59 +0800
From: weiping zhang <zhangweiping@didichuxing.com>
Subject: [PATCH v2 3/3] block: add WARN_ON if bdi register fail
Message-ID: <389034ebd68d3c1f3e49fac68b783195c287ce56.1509415695.git.zhangweiping@didichuxing.com>
References: <cover.1509415695.git.zhangweiping@didichuxing.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Disposition: inline
In-Reply-To: <cover.1509415695.git.zhangweiping@didichuxing.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: axboe@kernel.dk, jack@suse.cz
Cc: linux-block@vger.kernel.org, linux-mm@kvack.org

device_add_disk need do more safety error handle, so this patch just
add WARN_ON.

Reviewed-by: Jan Kara <jack@suse.cz>
Signed-off-by: weiping zhang <zhangweiping@didichuxing.com>
---
 block/genhd.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/block/genhd.c b/block/genhd.c
index dd305c65ffb0..52834433878c 100644
--- a/block/genhd.c
+++ b/block/genhd.c
@@ -660,7 +660,7 @@ void device_add_disk(struct device *parent, struct gendisk *disk)
 
 	/* Register BDI before referencing it from bdev */
 	bdi = disk->queue->backing_dev_info;
-	bdi_register_owner(bdi, disk_to_dev(disk));
+	WARN_ON(bdi_register_owner(bdi, disk_to_dev(disk)));
 
 	blk_register_region(disk_devt(disk), disk->minors, NULL,
 			    exact_match, exact_lock, disk);
-- 
2.14.2

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
