Received: from mail3.iadfw.net ([209.196.123.3])
	by mx4.airmail.net with smtp (Exim 3.33 #1)
	id 16pezk-0001SL-00
	for linux-mm@kvack.org; Mon, 25 Mar 2002 18:39:24 -0600
Received: from debian from [209.144.230.185] by mail3.iadfw.net
	(/\##/\ Smail3.1.30.16 #30.61) with esmtp for <linux-mm@kvack.org> sender: <ahaas@neosoft.com>
	id <mS/16pf05-003811S@mail3.iadfw.net>; Mon, 25 Mar 2002 18:39:45 -0600 (CST)
Received: from arth by debian with local (Exim 3.34 #1 (Debian))
	id 16pfAz-0001Bg-00
	for <linux-mm@kvack.org>; Mon, 25 Mar 2002 18:51:01 -0600
Date: Mon, 25 Mar 2002 18:51:00 -0600
From: Art Haas <ahaas@neosoft.com>
Subject: [PATCH] 2nd try at radix-tree pagecache and 2.4.19-pre3-ac6
Message-ID: <20020325185100.A4563@debian>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi.

Changes since the first version ...
1) Removed any remaining references to pagecache_lock in filemap.c
   vmscan.c as the variable has been removed.

2) Modified a __find_page() call to radix_tree_lookup()
   in filemap.c. This change is meant to fix a problem
   pointed out by Christoph Hellwig.

I've built the kernel with the patch, and it's running now,
and seems to be working well. Once again, all comments and
suggestions welcomed, and my thanks to all the VM coders.

-- 
They that can give up essential liberty to obtain a little temporary
safety deserve neither liberty nor safety.
 -- Benjamin Franklin, Historical Review of Pennsylvania, 1759
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
