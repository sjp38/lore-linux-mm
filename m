Message-Id: <3.0.6.32.20030127224726.00806c20@boo.net>
Date: Mon, 27 Jan 2003 22:47:26 -0500
From: Jason Papadopoulos <jasonp@boo.net>
Subject: [PATCH] page coloring for 2.5.59 kernel, version 1
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

This is yet another holding action, a port of my page coloring patch
to the 2.5 kernel. This is a minimal port (x86 only) intended to get
some testing done; once again the algorithm used is the same as in 
previous patches. There are several cleanups and removed 2.4-isms that
make the code somewhat more compact, though.

I'll be experimenting with other coloring schemes later this week.

www.boo.net/~jasonp/page_color-2.5.59-20030127.patch

Feedback of any sort welcome.

jasonp
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
