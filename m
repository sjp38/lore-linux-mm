Message-Id: <20070128131343.628722000@programming.kicks-ass.net>
Date: Sun, 28 Jan 2007 14:13:43 +0100
From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: [PATCH 00/14] Concurrent Page Cache
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-kernel@vger.kernel.org, linux-mm@kvack.org
Cc: Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Christoph Lameter <clameter@sgi.com>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>, Peter Zijlstra <a.p.zijlstra@chello.nl>
List-ID: <linux-mm.kvack.org>

With Nick leading the way to getting rid of the read side of the tree_lock,
this work continues by breaking the write side of said lock.

Aside from breaking MTD this version of the concurrent page cache seems
rock solid on my dual core x86_64 box.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
