Received: from wildwood.eecs.umich.edu (haih@wildwood.eecs.umich.edu [141.213.4.68])
	by smtp.eecs.umich.edu (8.12.3/8.12.3) with ESMTP id g7K21dYX012833
	for <linux-mm@kvack.org>; Mon, 19 Aug 2002 22:01:39 -0400
Date: Mon, 19 Aug 2002 22:09:50 -0400 (EDT)
From: Hai Huang <haih@eecs.umich.edu>
Subject: active_mm and mm
Message-ID: <Pine.LNX.4.33.0208192207430.18993-100000@wildwood.eecs.umich.edu>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

In struct task_struct, what's the difference between active_mm and mm?  I
vaguely remembers it's used for reducing cache overhead during context
switch, is this right or I'm totally off.  Thanks

-
Hai

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
