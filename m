Subject: mm1/2 stops while booting
From: dave! <ag051379@hotmail.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1061985422.4317.14.camel@federal-ohtekie>
Mime-Version: 1.0
Date: Wed, 27 Aug 2003 21:57:02 +1000
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi

test4-mm1 and mm2 just stall while booting for me at this part of
bootup, disk activity stops, waited a few minutes but still nothing

drivers/usb/core/usb.c: registered new driver hid
drivers/usb/input/hid-core.c: v2.0:USB HID core driver
mice: PS/2 mouse device common for all mice
gamecon.c: Pad type -1069438251 unknown
input: PSX controller on parport0

then nothing...

Ive used most versions of the mm patchset with the test kernels without
problems, havnt tried vanilla test4 yet, but before I do how do I go
about capturing the text from a failed boot? I'm using grub btw
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
