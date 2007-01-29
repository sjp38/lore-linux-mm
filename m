Date: Mon, 29 Jan 2007 09:20:25 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [PATCH 00/14] Concurrent Page Cache
In-Reply-To: <20070128131343.628722000@programming.kicks-ass.net>
Message-ID: <Pine.LNX.4.64.0701290918260.28330@schroedinger.engr.sgi.com>
References: <20070128131343.628722000@programming.kicks-ass.net>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, Andrew Morton <akpm@osdl.org>, Nick Piggin <nickpiggin@yahoo.com.au>, Ingo Molnar <mingo@elte.hu>, Rik van Riel <riel@redhat.com>
List-ID: <linux-mm.kvack.org>

On Sun, 28 Jan 2007, Peter Zijlstra wrote:

> With Nick leading the way to getting rid of the read side of the tree_lock,
> this work continues by breaking the write side of said lock.

Could we get the read side in separately from the write side? I think I 
get the read side but the write side still looks scary to me and 
introduces new ways of locking. Ladder locking?
 
> Aside from breaking MTD this version of the concurrent page cache seems
> rock solid on my dual core x86_64 box.

What exactly is the MTD doing and how does it break?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
