Subject: Re: vDSO vs. mm : problems with ppc vdso
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20060227222055.4d877f16.akpm@osdl.org>
References: <1141105154.3767.27.camel@localhost.localdomain>
	 <20060227215416.2bfc1e18.akpm@osdl.org>
	 <1141106896.3767.34.camel@localhost.localdomain>
	 <20060227222055.4d877f16.akpm@osdl.org>
Content-Type: text/plain
Date: Tue, 28 Feb 2006 17:30:19 +1100
Message-Id: <1141108220.3767.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@osdl.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

> It should be done with some care - I suspect this will become *the*
> way in which we recognise a 64-bit mm and quite a bit of stuff will end up
> migrating to it.  We do need input from the various 64-bit people who have
> wrestled with these things.

Patch send, now let's get feedback ;)

> > I'll send the patch as a reply to this message.
> 
> Please copy linux-arch.

Did that.

> It's not ->mapping.  It's the fact that rmap only operates on pages which
> were found on the LRU.  If you don't add it to the LRU (and surely you do
> not) then no problem.

Ok.

> > Do you gus see any other case where my "special" vma & those kernel
> > pages in could be a problem ?
> 
> It sounds just like a sound card DMA buffer to me - that's a solved
> problem?  (Well, we keep unsolving it, but it's a relatively common
> pattern).

Might be ... though I though the later had VM_RESERVED or some similar
thing ... the trick with that vma is that i don't want any of these
things to allow for COW ... But yeah, it _looks_ like it will just work
(well... it appears to work so far anyway....)

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
