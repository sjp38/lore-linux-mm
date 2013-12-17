Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f171.google.com (mail-pd0-f171.google.com [209.85.192.171])
	by kanga.kvack.org (Postfix) with ESMTP id 7491C6B003C
	for <linux-mm@kvack.org>; Tue, 17 Dec 2013 01:11:43 -0500 (EST)
Received: by mail-pd0-f171.google.com with SMTP id z10so6348497pdj.30
        for <linux-mm@kvack.org>; Mon, 16 Dec 2013 22:11:43 -0800 (PST)
Received: from LGEAMRELO02.lge.com (lgeamrelo02.lge.com. [156.147.1.126])
        by mx.google.com with ESMTP id sa6si10874967pbb.23.2013.12.16.22.11.40
        for <linux-mm@kvack.org>;
        Mon, 16 Dec 2013 22:11:41 -0800 (PST)
From: Minchan Kim <minchan@kernel.org>
Subject: [PATCH 4/5] zram: add zram maintainers
Date: Tue, 17 Dec 2013 15:12:02 +0900
Message-Id: <1387260723-15817-5-git-send-email-minchan@kernel.org>
In-Reply-To: <1387260723-15817-1-git-send-email-minchan@kernel.org>
References: <1387260723-15817-1-git-send-email-minchan@kernel.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: Nitin Gupta <ngupta@vflare.org>, linux-kernel@vger.kernel.org, Jens Axboe <axboe@kernel.dk>, linux-mm@kvack.org, Minchan Kim <minchan@kernel.org>

This patch adds maintainer information for zram into the MAINTAINERS
file.

Cc: Nitin Gupta <ngupta@vflare.org>
Signed-off-by: Minchan Kim <minchan@kernel.org>
---
 MAINTAINERS |    8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/MAINTAINERS b/MAINTAINERS
index d077c89b0440..7b32aa4b5f04 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -9692,6 +9692,14 @@ T:	Mercurial http://linuxtv.org/hg/v4l-dvb
 S:	Odd Fixes
 F:	drivers/media/pci/zoran/
 
+ZRAM COMPRESSED RAM BLOCK DEVICE DRVIER
+M:	Minchan Kim <minchan@kernel.org>
+M:	Nitin Gupta <ngupta@vflare.org>
+L:	linux-kernel@vger.kernel.org
+S:	Maintained
+F:	drivers/block/zram/
+F:	Documentation/blockdev/zram.txt
+
 ZS DECSTATION Z85C30 SERIAL DRIVER
 M:	"Maciej W. Rozycki" <macro@linux-mips.org>
 S:	Maintained
-- 
1.7.9.5

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
