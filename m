Received: from linuxjedi.org (IDENT:root@localhost.localdomain [127.0.0.1])
	by penguin.roanoke.edu (8.11.0/8.11.0) with ESMTP id f2QEJhn13999
	for <linux-mm@kvack.org>; Mon, 26 Mar 2001 09:19:43 -0500
Message-ID: <3ABF501D.CB800A16@linuxjedi.org>
Date: Mon, 26 Mar 2001 09:20:13 -0500
From: "David L. Parsley" <parsley@linuxjedi.org>
MIME-Version: 1.0
Subject: memory mgmt/tuning for diskless machines
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi,

I'm working on a project for building diskless multimedia terminals/game
consoles.  One issue I'm having is my terminal seems to go OOM and crash
from time to time.  It's strange, I would expect the OOM killer to blow
away X, but it doesn't - the machine just becomes unresponsive.

Since this is a quasi-embedded platform, what I'd REALLY like to do is
tune the vm so mallocs fail when freepages falls below a certain point. 
I'm using cramfs, and what I suspect is happening is that once memory
gets too low, the kernel doesn't have enough memory to uncompress
pages.  Since there's no swap, there's nothing to page out.

So... it occured to me I could tune this with /proc/sys/vm/freepages -
but now I find that it's read-only, and I can't echo x y z > freepages
like I used to.  What's up with that?

Suggestions?

regards,
	David
-- 
David L. Parsley
Network Administrator
Roanoke College
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux.eu.org/Linux-MM/
