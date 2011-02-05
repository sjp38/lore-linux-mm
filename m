Return-Path: <owner-linux-mm@kvack.org>
Received: from mail191.messagelabs.com (mail191.messagelabs.com [216.82.242.19])
	by kanga.kvack.org (Postfix) with ESMTP id BBF668D0039
	for <linux-mm@kvack.org>; Sat,  5 Feb 2011 12:36:57 -0500 (EST)
Date: Sat, 5 Feb 2011 09:36:32 -0800
From: Randy Dunlap <randy.dunlap@oracle.com>
Subject: [PATCH -mmotm] staging/easycap: fix build when SND is not enabled
Message-Id: <20110205093632.b76be846.randy.dunlap@oracle.com>
In-Reply-To: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
References: <201102042349.p14NnQEm025834@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: akpm@linux-foundation.org, rmthomas@sciolus.org, driverdevel <devel@driverdev.osuosl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org, gregkh <greg@kroah.com>

From: Randy Dunlap <randy.dunlap@oracle.com>

Fix easycap build when CONFIG_SOUND is enabled but CONFIG_SND is
not enabled.

These functions are only built when CONFIG_SND is enabled, so the
driver should depend on SND.
This means that having SND enabled is required for the (obsolete)
EASYCAP_OSS config option.

drivers/built-in.o: In function `easycap_usb_disconnect':
easycap_main.c:(.text+0x2aba20): undefined reference to `snd_card_free'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b784b): undefined reference to `snd_card_create'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b78fb): undefined reference to `snd_pcm_new'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b7916): undefined reference to `snd_pcm_set_ops'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b795b): undefined reference to `snd_card_register'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b79d8): undefined reference to `snd_card_free'
drivers/built-in.o: In function `easycap_alsa_probe':
(.text+0x2b7a78): undefined reference to `snd_card_free'
drivers/built-in.o: In function `easycap_alsa_complete':
(.text+0x2b7e68): undefined reference to `snd_pcm_period_elapsed'
drivers/built-in.o:(.data+0x2cae8): undefined reference to `snd_pcm_lib_ioctl'

Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>
Cc: R.M. Thomas <rmthomas@sciolus.org>
---
 drivers/staging/easycap/Kconfig |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

--- mmotm-2011-0204-1515.orig/drivers/staging/easycap/Kconfig
+++ mmotm-2011-0204-1515/drivers/staging/easycap/Kconfig
@@ -1,6 +1,6 @@
 config EASYCAP
 	tristate "EasyCAP USB ID 05e1:0408 support"
-	depends on USB && VIDEO_DEV && SOUND
+	depends on USB && VIDEO_DEV && SND
 
 	---help---
 	  This is an integrated audio/video driver for EasyCAP cards with

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
