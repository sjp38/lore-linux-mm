Message-Id: <20061207161800.426936000@chello.nl>
Date: Thu, 07 Dec 2006 17:18:00 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/16] concurrent pagecache (against 2.6.19-rt)
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

Based on Nick's lockless (read-side) pagecache patches (included in the series)
here an attempt to make the write side concurrent.

The patches survive some beating under PREEMPT_RT, but no performance 
measurements have been done yet.

I know everybody is busy stuffing patches Linus' way and should probably wait
a bit so folks have time to look, but here goes anyway...

Comment away ;-)

--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
