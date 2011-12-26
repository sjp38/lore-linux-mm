Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx204.postini.com [74.125.245.204])
	by kanga.kvack.org (Postfix) with SMTP id A230F6B005D
	for <linux-mm@kvack.org>; Mon, 26 Dec 2011 04:24:26 -0500 (EST)
From: Sumit Semwal <sumit.semwal@ti.com>
Subject: [PATCH 3/3] dma-buf: mark EXPERIMENTAL for 1st release.
Date: Mon, 26 Dec 2011 14:53:17 +0530
Message-ID: <1324891397-10877-4-git-send-email-sumit.semwal@ti.com>
In-Reply-To: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
References: <1324891397-10877-1-git-send-email-sumit.semwal@ti.com>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org, linux-mm@kvack.org, linaro-mm-sig@lists.linaro.org, dri-devel@lists.freedesktop.org, linux-media@vger.kernel.org, arnd@arndb.de, airlied@redhat.com
Cc: linux@arm.linux.org.uk, jesse.barker@linaro.org, m.szyprowski@samsung.com, rob@ti.com, daniel@ffwll.ch, t.stanislaws@samsung.com, patches@linaro.org, Sumit Semwal <sumit.semwal@ti.com>, Sumit Semwal <sumit.semwal@linaro.org>

Mark dma-buf buffer sharing API as EXPERIMENTAL for first release.
We will remove this in later versions, once it gets smoothed out
and has more users.

Signed-off-by: Sumit Semwal <sumit.semwal@linaro.org>
Signed-off-by: Sumit Semwal <sumit.semwal@ti.com>
---
 drivers/base/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

diff --git a/drivers/base/Kconfig b/drivers/base/Kconfig
index 8a0e87f..e95c67e 100644
--- a/drivers/base/Kconfig
+++ b/drivers/base/Kconfig
@@ -178,6 +178,7 @@ config DMA_SHARED_BUFFER
 	bool "Buffer framework to be shared between drivers"
 	default n
 	select ANON_INODES
+	depends on EXPERIMENTAL
 	help
 	  This option enables the framework for buffer-sharing between
 	  multiple drivers. A buffer is associated with a file using driver
-- 
1.7.5.4

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
