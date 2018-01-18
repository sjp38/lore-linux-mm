Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf0-f198.google.com (mail-pf0-f198.google.com [209.85.192.198])
	by kanga.kvack.org (Postfix) with ESMTP id 149866B0253
	for <linux-mm@kvack.org>; Thu, 18 Jan 2018 11:49:31 -0500 (EST)
Received: by mail-pf0-f198.google.com with SMTP id g186so8015612pfb.11
        for <linux-mm@kvack.org>; Thu, 18 Jan 2018 08:49:31 -0800 (PST)
Received: from NAM03-CO1-obe.outbound.protection.outlook.com (mail-co1nam03on0070.outbound.protection.outlook.com. [104.47.40.70])
        by mx.google.com with ESMTPS id x8-v6si29525plo.616.2018.01.18.08.49.29
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Thu, 18 Jan 2018 08:49:29 -0800 (PST)
From: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
Subject: [PATCH 4/4] drm/amdgpu: Use drm_oom_badness for amdgpu.
Date: Thu, 18 Jan 2018 11:47:52 -0500
Message-ID: <1516294072-17841-5-git-send-email-andrey.grodzovsky@amd.com>
In-Reply-To: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
References: <1516294072-17841-1-git-send-email-andrey.grodzovsky@amd.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org, dri-devel@lists.freedesktop.org, amd-gfx@lists.freedesktop.org
Cc: Christian.Koenig@amd.com, Andrey Grodzovsky <andrey.grodzovsky@amd.com>

Signed-off-by: Andrey Grodzovsky <andrey.grodzovsky@amd.com>
---
 drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
index 46a0c93..6a733cdc8 100644
--- a/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
+++ b/drivers/gpu/drm/amd/amdgpu/amdgpu_drv.c
@@ -828,6 +828,7 @@ static const struct file_operations amdgpu_driver_kms_fops = {
 #ifdef CONFIG_COMPAT
 	.compat_ioctl = amdgpu_kms_compat_ioctl,
 #endif
+	.oom_file_badness = drm_oom_badness,
 };
 
 static bool
-- 
2.7.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
