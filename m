Subject: [PATCH] missing space in printk message (was Re: 2.6.1-mm5)
References: <20040120000535.7fb8e683.akpm@osdl.org>
From: Sean Neakums <sneakums@zork.net>
Date: Tue, 20 Jan 2004 13:45:01 +0000
In-Reply-To: <20040120000535.7fb8e683.akpm@osdl.org> (Andrew Morton's
 message of "Tue, 20 Jan 2004 00:05:35 -0800")
Message-ID: <6ur7xuzqci.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>, vojtech@suse.cz
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Against 2.6.1-mm5.


--- S1-mm5/drivers/input/keyboard/atkbd.c~	2004-01-20 13:36:13.000000000 +0000
+++ S1-mm5/drivers/input/keyboard/atkbd.c	2004-01-20 13:36:24.000000000 +0000
@@ -279,7 +279,7 @@
 				atkbd->translated ? "translated" : "raw", 
 				atkbd->set, code, serio->phys);
 			if (atkbd->translated && atkbd->set == 2 && code == 0x7a)
-				printk(KERN_WARNING "atkbd.c: This is an XFree86 bug. It shouldn't access"
+				printk(KERN_WARNING "atkbd.c: This is an XFree86 bug. It shouldn't access "
 					"hardware directly.\n");
 			else
 				printk(KERN_WARNING "atkbd.c: Use 'setkeycodes %s%02x <keycode>' to make it known.\n",						code & 0x80 ? "e0" : "", code & 0x7f);
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
