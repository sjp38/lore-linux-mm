Received: from localhost (gandalf@localhost)
	by tux.rsn.hk-r.se (8.11.0.Beta1/8.11.0.Beta1/Debian 8.11.0-1) with ESMTP id e52EUuE08847
	for <linux-mm@kvack.org>; Fri, 2 Jun 2000 16:30:57 +0200
Date: Fri, 2 Jun 2000 16:30:52 +0200 (CEST)
From: Martin Josefsson <gandalf@wlug.westbo.se>
Subject: Reil's vm-patch against -ac7
Message-ID: <Pine.LNX.4.21.0006021627320.8574-100000@tux.rsn.hk-r.se>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all.

I just have to say, good work!

This patch has improved the performance of my machine quite a bit
(128MB ram, normal workstation).

Before applying this patch it was almost impossible to use the machine at
the same time as I was downloading a file at ~3MB/s
Now I hardly notice it. One thing I notice is that my currently running
programs are swapped out in favour of this new file that only gets stored
to disk.

Keep up the good work!

/Martin

The three best things about going to school are June, July, and August.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
