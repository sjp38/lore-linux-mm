Received: from localhost (haih@localhost [127.0.0.1])
	by azure.engin.umich.edu (8.9.3/8.9.1) with ESMTP id MAA08791
	for <linux-mm@kvack.org>; Mon, 5 Aug 2002 12:49:06 -0400 (EDT)
Date: Mon, 5 Aug 2002 12:49:06 -0400 (EDT)
From: Hai Huang <haih@engin.umich.edu>
Subject: How to compile kernel fast
Message-ID: <Pine.SOL.4.33.0208051244340.24796-100000@azure.engin.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

I've noticed that 2.4 kernel compile is much time consuming than 2.2.
Even very small changes would cause a chain reaction to force other source
files to be recompiled.  Did anyone ever experienced using pvm or
something similar to hasten this process with multiple machines running
parallel?  Well, this might not be the right ng to post this, but I figure
VM's dependency is pretty widespread in the kernel, so this is especially
problemsome in this area.  Any good suggestion is welcome.  Thanks.

-
Hai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
