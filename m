Date: Tue, 31 Aug 1999 10:23:37 +0200 (MET DST)
From: Gilles Pokam <pokam@cs.tu-berlin.de>
Subject: Re: question on remap_page_range()
In-Reply-To: <14281.20264.576540.243956@dukat.scot.redhat.com>
Message-ID: <Pine.SOL.4.10.9908311000590.16664-100000@elf>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Stephen C. Tweedie" <sct@redhat.com>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Sun, 29 Aug 1999, Stephen C. Tweedie wrote:
> 
> On Sat, 28 Aug 1999 12:03:41 +0200 (MET DST), Gilles Pokam
> <pokam@cs.tu-berlin.de> said:
> 
> >    In Rubini's book it is said that the so-called "physical
> >    address" is in reality a virtual address offset by PAGE_OFFSET from the 
> >    real physical address:
> 
> No.  Either Rubini is wrong or you have misinterpreted.  A physical
> address is just that --- the physical address of the memory as it
> appears on the cpu bus when the cpu goes to read from ram.  It is
> completely untranslated.  The first physical address in the system is
> usually zero, not PAGE_OFFSET.  

Sorry, i forget to said "from the kernel point of vue" :

Rubini's book, page 274 about PAGE_OFFSET:

" (...) PAGE_OFFSET must be considered whenever "physical" addresses are
used. What the kernel considers to be a physical address is actually a
virtual address, offset by PAGE_OFFSET from the real physical
address.(..)"

> > 	phys = real_phys + PAGE_OFFSET 
> 
> No, phys == real_phys.  The *virtual* address is real_phys +
> PAGE_OFFSET.  You can convert between the two using phys_to_virt() and
> virt_to_phys().

In this sense Rubini means that : kernel physical address = virtual
address ??

> > 2. But now i have tried to run my code on a x86 2.2.x kernel and the 
> >    remap_page_range function fails! When i ignore the PAGE_OFFSET macro
> >    it works strangely ...! 
> 
> Yes.  remap_page_range is designed to remap real, honest physical
> addresses.  These addresses have no translation applied:
> remap_page_range is supposed to be able to work even if applied to some
> physical address that is outside the normal kernel virtual address
> translation pages (eg. video framebuffers).

About remap_page_range Rubini said: (page 280-281)
" remap_page_range(unsigned long virt_addr,unsigned long phys_add,
	          unsigned log size,pgprot_t prot);
 unsigned long phys_add:
    The phyical address to which the virtual address should be mapped. The
    address is physical in the sense outline above" (in PAGE_OFFSET)
 
To map to user space a region of memory beginning at physical address
simple_region_start with size = simple_region_size he used the following
example:
unsigned long physical = simple_region_start + off + PAGE_OFFSET

physical was the argument passed to the remap_page_range function. I was
confusing here because the remap_page_range function in this example  
seems to take a virtual address instead of the real physical address.

Thanks
--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://humbolt.geo.uu.nl/Linux-MM/
