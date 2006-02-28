Date: Mon, 27 Feb 2006 22:47:39 -0800
From: Andrew Morton <akpm@osdl.org>
Subject: Re: vDSO vs. mm : problems with ppc vdso
Message-Id: <20060227224739.70ecfd08.akpm@osdl.org>
In-Reply-To: <1141108220.3767.43.camel@localhost.localdomain>
References: <1141105154.3767.27.camel@localhost.localdomain>
	<20060227215416.2bfc1e18.akpm@osdl.org>
	<1141106896.3767.34.camel@localhost.localdomain>
	<20060227222055.4d877f16.akpm@osdl.org>
	<1141108220.3767.43.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Cc: linux-mm@kvack.org, hugh@veritas.com, paulus@samba.org, nickpiggin@yahoo.com.au, davem@davemloft.net
List-ID: <linux-mm.kvack.org>

Benjamin Herrenschmidt <benh@kernel.crashing.org> wrote:
>
> > > I'll send the patch as a reply to this message.
>  > 
>  > Please copy linux-arch.
> 
>  Did that.

You did not, you meanie.

>  > > pages in could be a problem ?
>  > 
>  > It sounds just like a sound card DMA buffer to me - that's a solved
>  > problem?  (Well, we keep unsolving it, but it's a relatively common
>  > pattern).
> 
>  Might be ... though I though the later had VM_RESERVED or some similar
>  thing ... the trick with that vma is that i don't want any of these
>  things to allow for COW ... But yeah, it _looks_ like it will just work
>  (well... it appears to work so far anyway....)

Hugh's the man - he loves that stuff.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
