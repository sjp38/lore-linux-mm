Received: from wildwood.eecs.umich.edu (haih@wildwood.eecs.umich.edu [141.213.4.68])
	by smtp.eecs.umich.edu (8.12.3/8.12.3) with ESMTP id g8O3pUdi010571
	for <linux-mm@kvack.org>; Mon, 23 Sep 2002 23:51:45 -0400
Date: Mon, 23 Sep 2002 23:53:43 -0400 (EDT)
From: Hai Huang <haih@eecs.umich.edu>
Subject: page_launder*() functions
Message-ID: <Pine.LNX.4.33.0209232350420.11814-100000@wildwood.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Why aren't page_launder*() functions defined as static in vmscan.c since
they're only used within this file?  It's exporting something that's
unncessarily exported.  I'm looking at 2.4.18-3 kernel, maybe newer
versions fixed this???

-
Hai Huang

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
