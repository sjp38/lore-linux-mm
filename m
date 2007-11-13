Subject: Re: [RFC] Changing VM_PFNMAP assumptions and rules
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Reply-To: benh@kernel.crashing.org
In-Reply-To: <6934efce0711121553s6b88d1qe48b19adee1b7a85@mail.gmail.com>
References: <6934efce0711091115i3f859a00id0b869742029b661@mail.gmail.com>
	 <200711111109.34562.nickpiggin@yahoo.com.au>
	 <6934efce0711121403h2623958cq49490077c586924f@mail.gmail.com>
	 <1194906542.18185.73.camel@pasglop>
	 <6934efce0711121553s6b88d1qe48b19adee1b7a85@mail.gmail.com>
Content-Type: text/plain
Date: Tue, 13 Nov 2007 11:24:33 +1100
Message-Id: <1194913473.18185.80.camel@pasglop>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jared Hulbert <jaredeh@gmail.com>
Cc: Nick Piggin <nickpiggin@yahoo.com.au>, Linux Memory Management List <linux-mm@kvack.org>
List-ID: <linux-mm.kvack.org>

On Mon, 2007-11-12 at 15:53 -0800, Jared Hulbert wrote:

> > > I have a page that is at a hardware level read-only.  What kind of
> > > rules can that page live under?  More importantly these PFN's get
> > > mapped in with a call to ioremap() in the mtd drivers.  So once I
> > > figure out how to SPARSE_MEM, hotplug these pages in I've got to
> hack
> > > the MTD to work with real pages.  Or something like that.  I'm not
> > > ready to take that on yet, I just don't understand it all enough
> yet.
> >
> > I think vm_normal_page() could use something like pfn_normal() which
> > isn't quite the same as pfn_valid()... or just use pfn_valid() but
> in
> > that case, that would mean removing a bunch of the BUG_ON's indeed.
> 
> That's exactly what my original patch does.  Would my patch break
> spufs?  Nick said my patch would break /dev/mem I think.

I missed your original patch. Can you resend it to me ? Nick, how would
it break /dev/mem ?

Cheers,
Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
