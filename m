Received: from wildwood.eecs.umich.edu (haih@wildwood.eecs.umich.edu [141.213.4.68])
	by smtp.eecs.umich.edu (8.12.3/8.12.3) with ESMTP id g8L55KGZ013626
	for <linux-mm@kvack.org>; Sat, 21 Sep 2002 01:05:20 -0400
Date: Sat, 21 Sep 2002 01:07:13 -0400 (EDT)
From: Hai Huang <haih@eecs.umich.edu>
Subject: An executable vs. a data file?
Message-ID: <Pine.LNX.4.33.0209210102100.24160-100000@wildwood.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

Inside linux kernel, is there anyway to differentiate whether a file is an
executable (i.e. "x" bit is on) or a data file "r or w" bit is on or both
given the inode that points to the file?

I've noticed this function "int permission(struct inode*, int mask)" in
namei.c.  However, when I pass in mingetty's inode and MAY_EXEC as the
mask into the permission() function, it returned 0.  Anyone knows why or
can suggest an alternative way to accomplish this?

Thanks a lot.

-
Hai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
