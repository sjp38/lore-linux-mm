Received: from webmail.andrew.cmu.edu (WEBMAIL2.andrew.cmu.edu [128.2.10.92])
	by smtp1.andrew.cmu.edu (8.12.10/8.12.10) with SMTP id i1GKKLZI030421
	for <linux-mm@kvack.org>; Mon, 16 Feb 2004 15:20:21 -0500
Message-ID: <2000.128.2.185.83.1076962818.squirrel@webmail.andrew.cmu.edu>
Date: Mon, 16 Feb 2004 15:20:18 -0500 (EST)
Subject: Question on kswapd interaction with page-map
From: "Anand Eswaran" <aeswaran@andrew.cmu.edu>
Reply-To: aeswaran@ece.cmu.edu
MIME-Version: 1.0
Content-Type: text/plain;charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi :

   I send a looooong mail yday to this list, have recieved no reply. I
assume it was too long : so here's the short one-line version.

  Could someone please answer this question:

1) If a system call grabs pagemap_lru_lock and holds on to it for a long
time , can bad things happen with kswapd , which contends for the same
lock?

Thanks a lot,
-----
Anand.
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
