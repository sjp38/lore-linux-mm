Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qk0-f198.google.com (mail-qk0-f198.google.com [209.85.220.198])
	by kanga.kvack.org (Postfix) with ESMTP id 7E17F6B0595
	for <linux-mm@kvack.org>; Fri, 18 May 2018 03:50:25 -0400 (EDT)
Received: by mail-qk0-f198.google.com with SMTP id y124-v6so6184456qkc.8
        for <linux-mm@kvack.org>; Fri, 18 May 2018 00:50:25 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id m42-v6sor5165885qvg.160.2018.05.18.00.50.24
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 18 May 2018 00:50:24 -0700 (PDT)
From: Kent Overstreet <kent.overstreet@gmail.com>
Subject: [PATCH 10/10] block: Add sysfs entry for fua support
Date: Fri, 18 May 2018 03:49:17 -0400
Message-Id: <20180518074918.13816-20-kent.overstreet@gmail.com>
In-Reply-To: <20180518074918.13816-1-kent.overstreet@gmail.com>
References: <20180518074918.13816-1-kent.overstreet@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-block@vger.kernel.org, linux-mm@kvack.org, Jens Axboe <axboe@kernel.dk>, Ingo Molnar <mingo@kernel.org>
Cc: Kent Overstreet <kent.overstreet@gmail.com>

Signed-off-by: Kent Overstreet <kent.overstreet@gmail.com>
---
 block/blk-sysfs.c | 11 +++++++++++
 1 file changed, 11 insertions(+)

diff --git a/block/blk-sysfs.c b/block/blk-sysfs.c
index cbea895a55..d6dd7d8198 100644
--- a/block/blk-sysfs.c
+++ b/block/blk-sysfs.c
@@ -497,6 +497,11 @@ static ssize_t queue_wc_store(struct request_queue *q, const char *page,
 	return count;
 }
 
+static ssize_t queue_fua_show(struct request_queue *q, char *page)
+{
+	return sprintf(page, "%u\n", test_bit(QUEUE_FLAG_FUA, &q->queue_flags));
+}
+
 static ssize_t queue_dax_show(struct request_queue *q, char *page)
 {
 	return queue_var_show(blk_queue_dax(q), page);
@@ -665,6 +670,11 @@ static struct queue_sysfs_entry queue_wc_entry = {
 	.store = queue_wc_store,
 };
 
+static struct queue_sysfs_entry queue_fua_entry = {
+	.attr = {.name = "fua", .mode = S_IRUGO },
+	.show = queue_fua_show,
+};
+
 static struct queue_sysfs_entry queue_dax_entry = {
 	.attr = {.name = "dax", .mode = S_IRUGO },
 	.show = queue_dax_show,
@@ -714,6 +724,7 @@ static struct attribute *default_attrs[] = {
 	&queue_random_entry.attr,
 	&queue_poll_entry.attr,
 	&queue_wc_entry.attr,
+	&queue_fua_entry.attr,
 	&queue_dax_entry.attr,
 	&queue_wb_lat_entry.attr,
 	&queue_poll_delay_entry.attr,
-- 
2.17.0
