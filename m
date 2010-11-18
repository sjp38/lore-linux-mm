Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id C1DAC6B004A
	for <linux-mm@kvack.org>; Thu, 18 Nov 2010 00:26:53 -0500 (EST)
Date: Wed, 17 Nov 2010 21:25:17 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] w1: fix ds2423 build, needs to select CRC16
Message-Id: <20101117212517.48069281.randy.dunlap@oracle.com>
In-Reply-To: <201011180135.oAI1Znl3017273@imap1.linux-foundation.org>
References: <201011180135.oAI1Znl3017273@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: akpm@linux-foundation.org, Mika Laitio <lamikr@pilppa.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix w1_ds2423 build:  needs to select CRC16.

w1_ds2423.c:(.text+0x9971d): undefined reference to `crc16'
w1_ds2423.c:(.text+0x9973a): undefined reference to `crc16'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: Mika Laitio <lamikr@pilppa.org>
---
 drivers/w1/slaves/Kconfig |    1 +
 1 file changed, 1 insertion(+)

--- mmotm-2010-1117-1703.orig/drivers/w1/slaves/Kconfig
+++ mmotm-2010-1117-1703/drivers/w1/slaves/Kconfig
@@ -18,6 +18,7 @@ config W1_SLAVE_SMEM
 
 config W1_SLAVE_DS2423
 	tristate "Counter 1-wire device (DS2423)"
+	select CRC16
 	help
 	  If you enable this you can read the counter values available
 	  in the DS2423 chipset from the w1_slave file under the

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
