Received: from snowcrash.cymru.net (snowcrash.cymru.net [163.164.160.3])
	by kvack.org (8.8.7/8.8.7) with ESMTP id OAA10191
	for <linux-mm@kvack.ORG>; Thu, 28 Jan 1999 14:20:04 -0500
Message-Id: <m105xmP-0007U1C@the-village.bc.nu>
From: alan@lxorguk.ukuu.org.uk (Alan Cox)
Subject: Re: [patch] fixed both processes in D state and the /proc/ oopses [Re: [patch] Fixed the race that was oopsing Linux-2.2.0]
Date: Thu, 28 Jan 1999 20:11:09 +0000 (GMT)
In-Reply-To: <Pine.LNX.3.95.990128110737.6130B-100000@penguin.transmeta.com> from "Linus Torvalds" at Jan 28, 99 11:11:49 am
Content-Type: text
Sender: owner-linux-mm@kvack.org
To: Linus Torvalds <torvalds@transmeta.com>
Cc: alan@lxorguk.ukuu.org.uk, sct@redhat.com, andrea@e-mind.com, linux-kernel@vger.rutgers.edu, werner@suse.de, mlord@pobox.com, davem@dm.COBALTMICRO.COM, gandalf@szene.CH, adamk@3net.net.pl, kiracofe.8@osu.edu, ksi@ksi-linux.COM, djf-lists@ic.NET, tomh@taz.ccs.fau.edu, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is the first of two "people fixes" - this isnt so major the 2nd is

o	Fix Erik Andersen's email


diff -u --new-file --recursive --exclude-from ../exclude linux.vanilla/CREDITS linux.ac/CREDITS
--- linux.vanilla/CREDITS	Sun Jan 24 19:55:28 1999
+++ linux.ac/CREDITS	Wed Jan 27 19:07:38 1999
@@ -49,12 +49,12 @@
 
 N: Erik Andersen
 E: andersee@debian.org
-W: http://www.inconnect.com/~andersen
+W: http://www.xmission.com/~andersen
 P: 1024/FC4CFFED 78 3C 6A 19 FA 5D 92 5A  FB AC 7B A5 A5 E1 FF 8E
 D: Maintainer of ide-cd and Uniform CD-ROM driver, 
 D: ATAPI CD-Changer support, Major 2.1.x CD-ROM update.
 S: 4538 South Carnegie Tech Street
-S: West Valley City, Utah 84120
+S: Salt Lake City, Utah 84120
 S: USA
 
 N: H. Peter Anvin


--
To unsubscribe, send a message with 'unsubscribe linux-mm my@address'
in the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
