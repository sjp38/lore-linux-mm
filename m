Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f198.google.com (mail-pf1-f198.google.com [209.85.210.198])
	by kanga.kvack.org (Postfix) with ESMTP id A41EA8E0001
	for <linux-mm@kvack.org>; Tue, 22 Jan 2019 10:23:22 -0500 (EST)
Received: by mail-pf1-f198.google.com with SMTP id t2so18504593pfj.15
        for <linux-mm@kvack.org>; Tue, 22 Jan 2019 07:23:22 -0800 (PST)
Received: from mail.kernel.org (mail.kernel.org. [198.145.29.99])
        by mx.google.com with ESMTPS id q9si16811659pgi.89.2019.01.22.07.23.21
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Tue, 22 Jan 2019 07:23:21 -0800 (PST)
From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: [PATCH] zswap: ignore debugfs_create_dir() return value
Date: Tue, 22 Jan 2019 16:21:08 +0100
Message-Id: <20190122152151.16139-9-gregkh@linuxfoundation.org>
MIME-Version: 1.0
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>, Seth Jennings <sjenning@redhat.com>, Dan Streetman <ddstreet@ieee.org>, linux-mm@kvack.org

When calling debugfs functions, there is no need to ever check the
return value.  The function can work or not, but the code logic should
never do something different based on this.

Cc: Seth Jennings <sjenning@redhat.com>
Cc: Dan Streetman <ddstreet@ieee.org>
Cc: linux-mm@kvack.org
Signed-off-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
---
 mm/zswap.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/mm/zswap.c b/mm/zswap.c
index a4e4d36ec085..f583d08f6e24 100644
--- a/mm/zswap.c
+++ b/mm/zswap.c
@@ -1262,8 +1262,6 @@ static int __init zswap_debugfs_init(void)
 		return -ENODEV;
 
 	zswap_debugfs_root = debugfs_create_dir("zswap", NULL);
-	if (!zswap_debugfs_root)
-		return -ENOMEM;
 
 	debugfs_create_u64("pool_limit_hit", 0444,
 			   zswap_debugfs_root, &zswap_pool_limit_hit);
-- 
2.20.1
