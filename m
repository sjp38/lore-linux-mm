Received: from localhost.localdomain (217.133.209.45) by mail-6.tiscali.it (6.7.016)
        id 3ECB414F00243B91 for linux-mm@kvack.org; Sun, 25 May 2003 14:50:44 +0200
Content-Type: text/plain;
  charset="iso-8859-1"
From: Daniele Bellucci <bellucda@tiscali.it>
Subject: Re: 2.5.69-mm9
Date: Sun, 25 May 2003 14:50:07 +0200
References: <20030525042759.6edacd62.akpm@digeo.com>
In-Reply-To: <20030525042759.6edacd62.akpm@digeo.com>
MIME-Version: 1.0
Content-Transfer-Encoding: 8BIT
Message-Id: <200305251450.07092.bellucda@tiscali.it>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>


--- linux-2.5.69-mm9-org/drivers/pnp/quirks.c   2003-05-26 14:07:28.000000000 +0200
+++ linux-2.5.69-mm9-my/drivers/pnp/quirks.c    2003-05-26 14:07:43.000000000 +0200
@@ -15,6 +15,7 @@
 #include <linux/types.h>
 #include <linux/kernel.h>
 #include <linux/string.h>
+#include <linux/slab.h>

 #ifdef CONFIG_PNP_DEBUG
        #define DEBUG

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
