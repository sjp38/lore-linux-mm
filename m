Date: Tue, 23 Aug 2005 07:39:41 +0200
From: Andi Kleen <ak@suse.de>
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
Message-ID: <20050823053941.GB14497@wotan.suse.de>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com> <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Mon, Aug 22, 2005 at 10:31:00PM +0100, Hugh Dickins wrote:
> Then add Hugh's pagefault scalability alternative on top.

Hmm - this means that a large munmap has to take another lock
for each freed page right? That could get a bit expensive.
While there are already some locks taken more might not be a good
idea.

-Andi
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
