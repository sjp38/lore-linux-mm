Date: Fri, 21 Jan 2005 17:54:26 -0800 (PST)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Extend clear_page by an order parameter
In-Reply-To: <16881.43936.632734.780383@cargo.ozlabs.ibm.com>
Message-ID: <Pine.LNX.4.58.0501211749300.27677@schroedinger.engr.sgi.com>
References: <Pine.LNX.4.58.0501041512450.1536@schroedinger.engr.sgi.com>
 <Pine.LNX.4.44.0501082103120.5207-100000@localhost.localdomain>
 <20050108135636.6796419a.davem@davemloft.net>
 <Pine.LNX.4.58.0501211210220.25925@schroedinger.engr.sgi.com>
 <16881.33367.660452.55933@cargo.ozlabs.ibm.com>
 <Pine.LNX.4.58.0501211545080.27045@schroedinger.engr.sgi.com>
 <16881.40893.35593.458777@cargo.ozlabs.ibm.com> <20050121164353.6f205fbc.akpm@osdl.org>
 <16881.43936.632734.780383@cargo.ozlabs.ibm.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mackerras <paulus@samba.org>
Cc: Andrew Morton <akpm@osdl.org>, davem@davemloft.net, hugh@veritas.com, linux-ia64@vger.kernel.org, torvalds@osdl.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Sat, 22 Jan 2005, Paul Mackerras wrote:

> Christoph's patch is bigger than it needs to be because he has to
> change all the occurrences of clear_page(x) to clear_page(x, 0), and
> then he has to change a lot of architectures' clear_page functions to
> be called _clear_page instead.  If he picked a different name for the
> "clear a higher order page" function it would end up being less
> invasive as well as less confusing.

I had the name "zero_page" in V1 and V2 of the patch where it was
separate. Then someone complained about code duplication.

> The argument that clear_page is called that because it clears a higher
> order page won't wash; all the clear_page implementations in his patch
> are perfectly capable of clearing any contiguous set of 2^order pages
> (oops, I mean "zero-order pages"), not just a "higher order page".

clear_page is called clear_page because it clears one page of *any* order
not just higher orders. zero-order pages are not segregated nor are they
intrisincally better just because they contain more memory ;-).
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
