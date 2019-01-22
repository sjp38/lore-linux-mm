Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id E1A708E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:22:09 -0500 (EST)
Received: by mail-pl1-f199.google.com with SMTP id g13so15594481plo.10
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:22:09 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id l4si16745108pgr.346.2019.01.22.07.22.08
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:22:08 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] mm: cleancache: no need to check return value of debugfs_create functions
Date: Tue, 22 Jan 2019 16:21:11 +0100
Message-Id: <20190122152151.16139-12-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/cleancache.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/mm/cleancache.c b/mm/cleancache.c
index 2bf12da9baa0..082fdda7aaa6 100644
--- a/mm/cleancache.c
+++ b/mm/cleancache.c
@@ -305,8 +305,7 @@ static int __init init_cleancache(void)
 {
 #ifdef CONFIG_DEBUG_FS
 	struct dentry *root = debugfs_create_dir("cleancache", NULL);
-	if (root == NULL)
-		return -ENXIO;
+
 	debugfs_create_u64("succ_gets", 0444, root, &cleancache_succ_gets);
 	debugfs_create_u64("failed_gets", 0444, root, &cleancache_failed_gets);
 	debugfs_create_u64("puts", 0444, root, &cleancache_puts);
-- 
2.20.1
