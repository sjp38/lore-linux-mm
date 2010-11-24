Return-Path: <owner-linux-mm@kvack.org>
Received: from mail138.messagelabs.com (mail138.messagelabs.com [216.82.249.35])
	by kanga.kvack.org (Postfix) with ESMTP id 10ACB6B0071
	for <linux-mm@kvack.org>; Wed, 24 Nov 2010 14:42:10 -0500 (EST)
Date: Wed, 24 Nov 2010 11:41:09 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm/-next] media: fix timblogiw kconfig & build error
Message-Id: <20101124114109.c78df4e1.randy.dunlap@oracle.com>
In-Reply-To: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
References: <201011240045.oAO0jYQ5016010@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Pelagicore AB <info@pelagicore.com>, linux-media@vger.kernel.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, Zimny Lech <napohybelskurwysynom2010@gmail.com>
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

timblogiw uses dma() interfaces and it selects TIMB_DMA for that
support.  However, drivers/dma/ is not built unless
CONFIG_DMA_ENGINE is enabled, so select/enable that symbol also.

drivers/built-in.o: In function `timblogiw_close':
timblogiw.c:(.text+0x4419fe): undefined reference to `dma_release_channel'
drivers/built-in.o: In function `buffer_release':
timblogiw.c:(.text+0x441a8d): undefined reference to `dma_sync_wait'
drivers/built-in.o: In function `timblogiw_open':
timblogiw.c:(.text+0x44212b): undefined reference to `__dma_request_channel'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
---
 drivers/media/video/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- mmotm-2010-1123-1612.orig/drivers/media/video/Kconfig
+++ mmotm-2010-1123-1612/drivers/media/video/Kconfig
@@ -669,6 +669,7 @@ config VIDEO_HEXIUM_GEMINI
 config VIDEO_TIMBERDALE
 	tristate "Support for timberdale Video In/LogiWIN"
 	depends on VIDEO_V4L2 && I2C
+	select DMA_ENGINE
 	select TIMB_DMA
 	select VIDEO_ADV7180
 	select VIDEOBUF_DMA_CONTIG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
