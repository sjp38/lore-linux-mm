Subject: Re: [PATCH] ppc64: Fix possible race with set_pte on a present PTE
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <Pine.LNX.4.58.0405252140550.15534@ppc970.osdl.org>
References: <1085369393.15315.28.camel@gaston>
	 <Pine.LNX.4.58.0405232046210.25502@ppc970.osdl.org>
	 <1085371988.15281.38.camel@gaston>
	 <Pine.LNX.4.58.0405232134480.25502@ppc970.osdl.org>
	 <1085373839.14969.42.camel@gaston>
	 <Pine.LNX.4.58.0405232149380.25502@ppc970.osdl.org>
	 <20040525034326.GT29378@dualathlon.random>
	 <Pine.LNX.4.58.0405242051460.32189@ppc970.osdl.org>
	 <20040525114437.GC29154@parcelfarce.linux.theplanet.co.uk>
	 <Pine.LNX.4.58.0405250726000.9951@ppc970.osdl.org>
	 <20040525153501.GA19465@foobazco.org>
	 <Pine.LNX.4.58.0405250841280.9951@ppc970.osdl.org>
	 <20040525102547.35207879.davem@redhat.com>
	 <Pine.LNX.4.58.0405251034040.9951@ppc970.osdl.org>
	 <20040525105442.2ebdc355.davem@redhat.com>
	 <Pine.LNX.4.58.0405251056520.9951@ppc970.osdl.org>
	 <1085521251.24948.127.camel@gaston>
	 <Pine.LNX.4.58.0405251452590.9951@ppc970.osdl.org>
	 <Pine.LNX.4.58.0405251455320.9951@ppc970.osdl.org>
	 <1085522860.15315.133.camel@gaston>
	 <Pine.LNX.4.58.0405251514200.9951@ppc970.osdl.org>
	 <1085530867.14969.143.camel@gaston>
	 <Pine.LNX.4.58.0405251749500.9951@ppc970.osdl.org>
	 <1085541906.14969.412.camel@gaston>
	 <Pine.LNX.4.58.0405252031270.15534@ppc970.osdl.org>
	 <1085544720.5580.9.camel@gaston> <1085545114.5578.11.camel@gaston>
	 <Pine.LNX.4.58.0405252140550.15534@ppc970.osdl.org>
Content-Type: text/plain
Message-Id: <1085546972.5580.23.camel@gaston>
Mime-Version: 1.0
Date: Wed, 26 May 2004 14:49:32 +1000
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@osdl.org>
Cc: "David S. Miller" <davem@redhat.com>, wesolows@foobazco.org, willy@debian.org, Andrea Arcangeli <andrea@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Kernel list <linux-kernel@vger.kernel.org>, mingo@elte.hu, bcrl@kvack.org, linux-mm@kvack.org, Linux Arch list <linux-arch@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

On Wed, 2004-05-26 at 14:50, Linus Torvalds wrote:
> On Wed, 26 May 2004, Benjamin Herrenschmidt wrote:
> >
> > Hrm... Still dies, some kind of loop it seems, I'll have a look
> 
> Are you sure the it's not just taking infinite page fault because we keep 
> reloading the old value from the hash tables? That "hash fault" thing 
> still doesn't convince me. Why should the hash-refill fastpath ever look 
> at the software page tables?

Where do you think the hash PTE is filled from ? :)

We even use one of the linux PTE bits as a lock bit during the hash
refill (the PAGE_BUSY bit) to avoid a race where we can end up filling
more than one hash entry from the same linux PTE.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
