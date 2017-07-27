Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pg0-f72.google.com (mail-pg0-f72.google.com [74.125.83.72])
	by kanga.kvack.org (Postfix) with ESMTP id D2E116B02FD
	for <linux-mm@kvack.org>; Thu, 27 Jul 2017 08:07:52 -0400 (EDT)
Received: by mail-pg0-f72.google.com with SMTP id w187so10615205pgb.10
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:52 -0700 (PDT)
Received: from mail-pg0-x242.google.com (mail-pg0-x242.google.com. [2607:f8b0:400e:c05::242])
        by mx.google.com with ESMTPS id e8si11564111pli.550.2017.07.27.05.07.51
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 27 Jul 2017 05:07:51 -0700 (PDT)
Received: by mail-pg0-x242.google.com with SMTP id y129so20366582pgy.3
        for <linux-mm@kvack.org>; Thu, 27 Jul 2017 05:07:51 -0700 (PDT)
From: Arvind Yadav <arvind.yadav.cs@gmail.com>
Subject: [PATCH 3/5] mm: page_idle: constify attribute_group structures.
Date: Thu, 27 Jul 2017 17:37:01 +0530
Message-Id: <1501157221-3832-1-git-send-email-arvind.yadav.cs@gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, minchan@kernel.org, vbabka@suse.cz, kirill.shutemov@linux.intel.com
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

attribute_group are not supposed to change at runtime. All functions
working with attribute_group provided by <linux/sysfs.h> work with
const attribute_group. So mark the non-const structs as const.

Signed-off-by: Arvind Yadav <arvind.yadav.cs@gmail.com>
---
 mm/page_idle.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_idle.c b/mm/page_idle.c
index 1b0f48c..4bd03a8 100644
--- a/mm/page_idle.c
+++ b/mm/page_idle.c
@@ -204,7 +204,7 @@ static ssize_t page_idle_bitmap_write(struct file *file, struct kobject *kobj,
 	NULL,
 };
 
-static struct attribute_group page_idle_attr_group = {
+static const struct attribute_group page_idle_attr_group = {
 	.bin_attrs = page_idle_bin_attrs,
 	.name = "page_idle",
 };
-- 
1.9.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
