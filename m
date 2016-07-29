Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f200.google.com (mail-io0-f200.google.com [209.85.223.200])
	by kanga.kvack.org (Postfix) with ESMTP id BC6846B025F
	for <linux-mm@kvack.org>; Fri, 29 Jul 2016 10:47:52 -0400 (EDT)
Received: by mail-io0-f200.google.com with SMTP id m130so134260766ioa.1
        for <linux-mm@kvack.org>; Fri, 29 Jul 2016 07:47:52 -0700 (PDT)
Received: from szxga03-in.huawei.com (szxga03-in.huawei.com. [119.145.14.66])
        by mx.google.com with ESMTPS id 39si14004529otw.240.2016.07.29.07.47.51
        for <linux-mm@kvack.org>
        (version=TLS1 cipher=AES128-SHA bits=128/128);
        Fri, 29 Jul 2016 07:47:52 -0700 (PDT)
From: zhongjiang <zhongjiang@huawei.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20fs=3A=20wipe=20off=20the=20compiler=20warn?=
Date: Fri, 29 Jul 2016 22:46:39 +0800
Message-ID: <1469803600-44293-1-git-send-email-zhongjiang@huawei.com>
MIME-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org

From: zhong jiang <zhongjiang@huawei.com>

when compile the kenrel code, I happens to the following warn.
fs/reiserfs/ibalance.c:1156:2: warning: a??new_insert_keya?? may be used
uninitialized in this function.
memcpy(new_insert_key_addr, &new_insert_key, KEY_SIZE);
^
The patch just fix it to avoid the warn.

Signed-off-by: zhong jiang <zhongjiang@huawei.com>
---
 fs/reiserfs/ibalance.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/fs/reiserfs/ibalance.c b/fs/reiserfs/ibalance.c
index b751eea..512ce95 100644
--- a/fs/reiserfs/ibalance.c
+++ b/fs/reiserfs/ibalance.c
@@ -818,7 +818,7 @@ int balance_internal(struct tree_balance *tb,
 	int order;
 	int insert_num, n, k;
 	struct buffer_head *S_new;
-	struct item_head new_insert_key;
+	struct item_head uninitialized_var(new_insert_key);
 	struct buffer_head *new_insert_ptr = NULL;
 	struct item_head *new_insert_key_addr = insert_key;
 
-- 
1.8.3.1

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
