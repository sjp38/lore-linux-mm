Date: Tue, 23 Aug 2005 08:01:41 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: [RFT][PATCH 2/2] pagefault scalability alternative
In-Reply-To: <20050823053941.GB14497@wotan.suse.de>
Message-ID: <Pine.LNX.4.61.0508230757410.5224@goblin.wat.veritas.com>
References: <Pine.LNX.4.61.0508222221280.22924@goblin.wat.veritas.com>
 <Pine.LNX.4.61.0508222229270.22924@goblin.wat.veritas.com>
 <20050823053941.GB14497@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andi Kleen <ak@suse.de>
Cc: Christoph Lameter <clameter@engr.sgi.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linus Torvalds <torvalds@osdl.org>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Tue, 23 Aug 2005, Andi Kleen wrote:
> 
> Hmm - this means that a large munmap has to take another lock
> for each freed page right? That could get a bit expensive.

I do hope not!  Where do you see that extra lock per page?

(The patch doesn't bring in locking per page-table-entry,
just locking per page-table.)

Hugh
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
