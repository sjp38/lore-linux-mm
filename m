Date: Mon, 10 Jan 2005 09:16:05 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Prezeroing V3 [1/4]: Allow request for zeroed memory
In-Reply-To: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
Message-ID: <Pine.LNX.4.58.0501100915200.19135@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Hugh Dickins <hugh@veritas.com>
Cc: Andrew Morton <akpm@osdl.org>, "David S. Miller" <davem@davemloft.net>, linux-ia64@vger.kernel.org, Linus Torvalds <torvalds@osdl.org>, linux-mm@kvack.org, Linux Kernel Development <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Sat, 8 Jan 2005, Hugh Dickins wrote:

> Christoph, a late comment: doesn't this effectively replace
> do_anonymous_page's clear_user_highpage by clear_highpage, which would
> be a bad idea (inefficient? or corrupting?) on those few architectures
> which actually do something with that user addr?

Yes. Right my ia64 centric vision got me again. Thanks for all the other
patches that were posted. I hope this is now all cleared up?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
