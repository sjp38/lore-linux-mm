Date: Fri, 19 Nov 2004 17:56:43 -0800 (PST)
From: Linus Torvalds <torvalds@osdl.org>
Subject: Re: page fault scalability patch V11 [0/7]: overview
In-Reply-To: <419E98E7.1080402@yahoo.com.au>
Message-ID: <Pine.LNX.4.58.0411191753130.2222@ppc970.osdl.org>
References: <Pine.LNX.4.44.0411061527440.3567-100000@localhost.localdomain>
  <Pine.LNX.4.58.0411181126440.30385@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411181715280.834@schroedinger.engr.sgi.com>
 <419D581F.2080302@yahoo.com.au>  <Pine.LNX.4.58.0411181835540.1421@schroedinger.engr.sgi.com>
  <419D5E09.20805@yahoo.com.au>  <Pine.LNX.4.58.0411181921001.1674@schroedinger.engr.sgi.com>
 <1100848068.25520.49.camel@gaston> <Pine.LNX.4.58.0411190704330.5145@schroedinger.engr.sgi.com>
 <Pine.LNX.4.58.0411191155180.2222@ppc970.osdl.org> <419E98E7.1080402@yahoo.com.au>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Christoph Lameter <clameter@sgi.com>, akpm@osdl.org, Benjamin Herrenschmidt <benh@kernel.crashing.org>, Hugh Dickins <hugh@veritas.com>, linux-mm@kvack.org, linux-ia64@vger.kernel.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


On Sat, 20 Nov 2004, Nick Piggin wrote:
> 
> The per thread rss may wrap (maybe not 64-bit counters), but even so,
> the summation over all threads should still end up being correct I
> think.

Yes. As long as the total rss fits in an int, it doesn't matter if any of
them wrap. Addition is still associative in twos-complement arithmetic 
even in the presense of overflows. 

If you actually want to make it proper standard C, I guess you'd have to 
make the thing unsigned, which gives you the mod-2**n guarantees even if 
somebody were to ever make a non-twos-complement machine.

		Linus
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
