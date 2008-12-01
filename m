Date: Mon, 1 Dec 2008 19:10:47 +0100
From: Nick Piggin <npiggin@suse.de>
Subject: Re: [patch][rfc] acpi: do not use kmem caches
Message-ID: <20081201181047.GK10790@wotan.suse.de>
References: <20081201083128.GB2529@wotan.suse.de> <84144f020812010318v205579ean57edecf7992ec7ef@mail.gmail.com> <20081201120002.GB10790@wotan.suse.de> <4933E2C3.4020400@gmail.com> <1228138641.14439.18.camel@penberg-laptop> <4933EE8A.2010007@gmail.com> <20081201161404.GE10790@wotan.suse.de> <4934149A.4020604@gmail.com> <20081201172044.GB14074@infradead.org> <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.00.0812011241080.3197@localhost.localdomain>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Len Brown <lenb@kernel.org>
Cc: Christoph Hellwig <hch@infradead.org>, Alexey Starikovskiy <aystarik@gmail.com>, Pekka Enberg <penberg@cs.helsinki.fi>, Linux Memory Management List <linux-mm@kvack.org>, linux-acpi@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Mon, Dec 01, 2008 at 12:53:04PM -0500, Len Brown wrote:
> 
> > Or at least stop arguing and throwing bureaucratic stones in the way of
> > those wanting to sort out this mess.
> 
> I think we all would be better served if there were more facts
> and fewer insults on this thread, can we do that please?
> 
> I do not think the extra work we need to do for ACPICA changes
> are a significant hurdle here. We will do what is best for Linux --
> which is what we though we were doing when we changed ACPICA
> so Linux could use native caching in the first place.
> 
> The only question that should be on the table here is how
> to make Linux be the best it can be.

If there is good reason to keep them around, I'm fine with that.
I think Pekka's suggestion of not doing unions but have better
typing in the code and then allocate the smaller types from
kmalloc sounds like a good idea.

If the individual kmem caches are here to stay, then the
kmem_cache_shrink call should go away. Either way we can delete
some code from slab.

The OS agnostic code that implements its own allocator is kind
of a hack -- I don't understand why you would turn on allocator
debugging and then circumvent it because you find it too slow.
But I will never maintain that so if it is compiled out for
Linux, then OK.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
