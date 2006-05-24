Date: Wed, 24 May 2006 15:20:46 +0100 (BST)
From: Hugh Dickins <hugh@veritas.com>
Subject: Re: tracking dirty pages patches
In-Reply-To: <1148425627.10561.32.camel@lappy>
Message-ID: <Pine.LNX.4.64.0605241516430.12355@blonde.wat.veritas.com>
References: <Pine.LNX.4.64.0605222022100.11067@blonde.wat.veritas.com>
 <1148425627.10561.32.camel@lappy>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@osdl.org>, Linus Torvalds <torvalds@osdl.org>, David Howells <dhowells@redhat.com>, linux-mm@kvack.org, Christoph Lameter <clameter@sgi.com>
List-ID: <linux-mm.kvack.org>

On Wed, 24 May 2006, Peter Zijlstra wrote:
> On Mon, 2006-05-22 at 20:31 +0100, Hugh Dickins wrote:
> 
> > I'm not convinced that optimize-follow_pages is a worthwhile optimization
> > (in some cases you're adding an atomic inc and dec), and it's irrelevant
> > to your tracking of dirty pages, but I don't feel strongly about it.
> > Except, if it stays then it needs fixing: the flags 0 case is doing
> > a put_page without having done a get_page.
> 
> Not sure on the benefit either, I just did it to educate myself on the
> subject (and blotched it on my way). Christoph kindly fixed the
> offending condition.
> 
> I guess this patch could really do with some numbers if found that the
> set_page_dirty() is needed at all.

Just drop that patch from the set.  It's a distraction from the rest,
and I believe we'll optimize it much better by removing those tests
and their set_page_dirty (but not immediately).

Hugh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
