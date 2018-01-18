Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-it0-f72.google.com (mail-it0-f72.google.com [209.85.214.72])
	by kanga.kvack.org (Postfix) with ESMTP id 823366B025E
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:48:40 -0500 (EST)
Received: by mail-it0-f72.google.com with SMTP id 14so10870002itm.6
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:48:40 -0800 (PST)
Received: from NAM02-BL2-obe.outbound.protection.outlook.com (mail-bl2nam02on0063.outbound.protection.outlook.com. [104.47.38.63])
        by mx.google.com with ESMTPS id m67si7137184ite.168.2018.01.18.08.48.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:48:39 -0800 (PST)
From: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Subject: [PATCH 1/4] fs: add OOM badness callback in file_operatrations struct.
Date: Thu, 18 Jan 2018 11:47:49 -0500
Message-ID: <1516294072-17841-2-git-send-email-andrey.grodzovsky@amd.com>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com, Andrey Grodzovsky <andrey.grodzovsky@amd.com>

This allows device drivers to specify an additional badness for the OOM
when they allocate memory on behalf of userspace.

Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
---
 include/linux/fs.h | 1 +
 1 file changed, 1 insertion(+)

diff --git a/include/linux/fs.h b/include/linux/fs.h
index 511fbaa..938394a 100644
--- a/include/linux/fs.h
+++ b/include/linux/fs.h
@@ -1728,6 +1728,7 @@ struct file_operations {
 			u64);
 	ssize_t (*dedupe_file_range)(struct file *, u64, u64, struct file *,
 			u64);
+	long (*oom_file_badness)(struct file *);
 } __randomize_layout;
 
 struct inode_operations {
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
