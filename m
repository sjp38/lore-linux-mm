Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f69.google.com (mail-it0-f69.google.com [209.85.214.69])
	by kanga.kvack.org (Postfix) with ESMTP id 497906B03AE
	for <linux-mm@kvack.org>; Wed, 15 Mar 2017 22:02:18 -0400 (EDT)
Received: by mail-it0-f69.google.com with SMTP id u69so35996515ita.1
        for <linux-mm@kvack.org>; Wed, 15 Mar 2017 19:02:18 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0084.hostedemail.com. [216.40.44.84])
        by mx.google.com with ESMTPS id b41si4667138ioj.178.2017.03.15.19.02.17
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 15 Mar 2017 19:02:17 -0700 (PDT)
From: Joe Perches <joe@perches.com>
Subject: [PATCH 14/15] mm: page_alloc: Use octal permissions
Date: Wed, 15 Mar 2017 19:00:11 -0700
Message-Id: <e95b6de24576f4e6317a2a53a49f912691fe5d01.1489628477.git.joe@perches.com>
In-Reply-To: <cover.1489628477.git.joe@perches.com>
References: <cover.1489628477.git.joe@perches.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org

Using S_<FOO> permissions can be hard to parse.
Using octal is typical.

Signed-off-by: Joe Perches <joe@perches.com>
---
 mm/page_alloc.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/mm/page_alloc.c b/mm/page_alloc.c
index efc3184aa6bc..930773b03b26 100644
--- a/mm/page_alloc.c
+++ b/mm/page_alloc.c
@@ -2863,7 +2863,7 @@ static bool should_fail_alloc_page(gfp_t gfp_mask, unsigned int order)
 
 static int __init fail_page_alloc_debugfs(void)
 {
-	umode_t mode = S_IFREG | S_IRUSR | S_IWUSR;
+	umode_t mode = S_IFREG | 0600;
 	struct dentry *dir;
 
 	dir = fault_create_debugfs_attr("fail_page_alloc", NULL,
-- 
2.10.0.rc2.1.g053435c

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
