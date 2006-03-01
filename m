Subject: Re: vDSO vs. mm : problems with ppc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <440505D0.2030802@yahoo.com.au>
References: <1141105154.3767.27.camel@localhost.localdomain>
	 <20060227215416.2bfc1e18.akpm@osdl.org>
	 <1141106896.3767.34.camel@localhost.localdomain>
	 <20060227222055.4d877f16.akpm@osdl.org>
	 <1141108220.3767.43.camel@localhost.localdomain>
	 <440424CA.5070206@yahoo.com.au>
	 <Pine.LNX.4.61.0602281213540.7059@goblin.wat.veritas.com>
	 <440505D0.2030802@yahoo.com.au>
Content-Type: text/plain
Date: Wed, 01 Mar 2006 13:26:59 +1100
Message-Id: <1141180019.4157.12.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <nickpiggin@yahoo.com.au>
Cc: Hugh Dickins <hugh@veritas.com>, Andrew Morton <akpm@osdl.org>, linux-mm@kvack.org, paulus@samba.org, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

On Wed, 2006-03-01 at 13:24 +1100, Nick Piggin wrote:
> Hugh Dickins wrote:
> > On Tue, 28 Feb 2006, Nick Piggin wrote:
> > 
> >>You should be OK. VM_RESERVED itself is something of an anachronism
> >>these days. If you're not getting your page from the page allocator
> >>then you'll want to make sure each of their count, and mapcount is
> >>reset before allowing them to be mapped.
> > 
> > 
> > Yes, it's fine that VM_RESERVED isn't set on it.
> > But I don't understand your remarks about count and mapcount at all:
> > perhaps you meant to say something else?
> > 
> 
> Yes, count should be elevated.
> 
> mapcount should be reset, to avoid the bug in page_remove_rmap.

Can you be more explicit ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
