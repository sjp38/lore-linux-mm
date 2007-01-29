Date: Mon, 29 Jan 2007 12:18:29 -0800 (PST)
From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [patch] mm: mremap correct rmap accounting
In-Reply-To: <20070129120325.26707d26.akpm@osdl.org>
Message-ID: <Pine.LNX.4.64.0701291216340.3611@woody.linux-foundation.org>
References: <45B61967.5000302@yahoo.com.au> <Pine.LNX.4.64.0701232041330.2461@blonde.wat.veritas.com>
 <45BD6A7B.7070501@yahoo.com.au> <Pine.LNX.4.64.0701291901550.8996@blonde.wat.veritas.com>
 <Pine.LNX.4.64.0701291123460.3611@woody.linux-foundation.org>
 <20070129120325.26707d26.akpm@osdl.org>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: Hugh Dickins <hugh@veritas.com>, Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management <linux-mm@kvack.org>, Ralf Baechle <ralf@linux-mips.org>
List-ID: <linux-mm.kvack.org>


On Mon, 29 Jan 2007, Andrew Morton wrote:
> 
> Can we convert those bits of mips to just have a single zero-page, like
> everyone else?
> 
> Is that trick a correctness thing, or a performance thing?  If the latter,
> how useful is it, and how common are the chips which use it?

It was a performance thing, iirc. Apparently a fairly big deal: pages 
kicking each other out of the cache due to idiotic cache design. But I 
forget any details.

MIPS in general is a f*cking pain in the *ss. They have a few chips that 
are sane, but just an incredible amount of totally braindamaged ones. 
They're not the only ones with virtual caches, but they're certainly 
well-represented there. Sad.

			Linus

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
