Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id C88806B004D
	for <linux-mm@kvack.org>; Sun, 15 Nov 2009 22:38:58 -0500 (EST)
Received: by iwn34 with SMTP id 34so3742440iwn.12
        for <linux-mm@kvack.org>; Sun, 15 Nov 2009 19:38:57 -0800 (PST)
MIME-Version: 1.0
Date: Mon, 16 Nov 2009 11:38:57 +0800
Message-ID: <2df346410911151938r1eb5c5e4q9930ac179d61ef01@mail.gmail.com>
Subject: [BUG]2.6.27.y some contents lost after writing to mmaped file
From: JiSheng Zhang <jszhang3@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
To: linux-kernel@vger.kernel.org
Cc: linux-mm@kvack.org, stable@kernel.org, gregkh@suse.de
List-ID: <linux-mm.kvack.org>

Hi,

I triggered a failure in an fs test with fsx-linux from ltp. It seems that
fsx-linux failed at mmap->write sequence.

Tested kernel is 2.6.27.12 and 2.6.27.39
Tested file system: ext3, tmpfs.
IMHO, it impacts all file systems.

Some fsx-linux log is:

READ BAD DATA: offset = 0x2771b, size = 0xa28e
OFFSET  GOOD    BAD     RANGE
0x287e0 0x35c9  0x15a9     0x80
operation# (mod 256) for the bad datamay be 21
...
7828: 1257514978.306753 READ     0x23dba thru 0x25699 (0x18e0 bytes)
7829: 1257514978.306899 MAPWRITE 0x27eeb thru 0x2a516 (0x262c bytes)
 ******WWWW
7830: 1257514978.307504 READ     0x2771b thru 0x319a8 (0xa28e bytes)
 ***RRRR***
Correct content saved for comparison
...

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
