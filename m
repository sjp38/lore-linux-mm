Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qt0-f200.google.com (mail-qt0-f200.google.com [209.85.216.200])
	by kanga.kvack.org (Postfix) with ESMTP id 2C0D96B0033
	for <linux-mm@kvack.org>; Thu,  5 Oct 2017 22:45:40 -0400 (EDT)
Received: by mail-qt0-f200.google.com with SMTP id o3so16057789qte.7
        for <linux-mm@kvack.org>; Thu, 05 Oct 2017 19:45:40 -0700 (PDT)
Received: from sasl.smtp.pobox.com (pb-smtp2.pobox.com. [64.147.108.71])
        by mx.google.com with ESMTPS id n1si447029qtf.239.2017.10.05.19.45.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 05 Oct 2017 19:45:39 -0700 (PDT)
From: Nicolas Pitre <nicolas.pitre@linaro.org>
Subject: [PATCH v5 2/5] cramfs: make cramfs_physmem usable as root fs
Date: Thu,  5 Oct 2017 22:45:28 -0400
Message-Id: <20171006024531.8885-3-nicolas.pitre@linaro.org>
In-Reply-To: <20171006024531.8885-1-nicolas.pitre@linaro.org>
References: <20171006024531.8885-1-nicolas.pitre@linaro.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Alexander Viro <viro@zeniv.linux.org.uk>, Christoph Hellwig <hch@infradead.org>
Cc: linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, linux-embedded@vger.kernel.org, linux-kernel@vger.kernel.org, Chris Brandt <Chris.Brandt@renesas.com>

Signed-off-by: Nicolas Pitre <nico@linaro.org>
Tested-by: Chris Brandt <chris.brandt@renesas.com>
---
 init/do_mounts.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/init/do_mounts.c b/init/do_mounts.c
index c2de5104aa..43b5817f60 100644
--- a/init/do_mounts.c
+++ b/init/do_mounts.c
@@ -556,6 +556,14 @@ void __init prepare_namespace(void)
 		ssleep(root_delay);
 	}
 
+	if (IS_ENABLED(CONFIG_CRAMFS_PHYSMEM) && root_fs_names &&
+	    !strcmp(root_fs_names, "cramfs_physmem")) {
+		int err = do_mount_root("cramfs", "cramfs_physmem",
+					root_mountflags, root_mount_data);
+		if (!err)
+			goto out;
+	}
+
 	/*
 	 * wait for the known devices to complete their probing
 	 *
-- 
2.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
