Subject: Re: Memory management questions
References: <cafjtv$76d$2@sea.gmane.org>
From: Sean Neakums <sneakums@zork.net>
Date: Sun, 13 Jun 2004 14:55:31 +0100
In-Reply-To: <cafjtv$76d$2@sea.gmane.org> (tyler@agat.net's message of "Sat,
	12 Jun 2004 21:02:16 +0200")
Message-ID: <6uekoj36lo.fsf@zork.zork.net>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Tyler <tyler@agat.net>
Cc: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Tyler <tyler@agat.net> writes:

> I've always thinked that paging or virtual memory was practical to
> avoid memory fragmentation. I thinked that you can map contiguous
> virtual pages to non contiguous physical page frames.
> But let's take a look at the macros __va(x) and __pa(x) :
> #define __pa(x) ((unsigned long)x-PAGE_OFFSET)
> #define __va(x) ((unsigned long)x+PAGE_OFFSET)
> PAGE_OFFSET is a constant. For me, this means that virtual contiguous
> adresses have to be mapped to contiguous physical adresses. Am I wrong
> ?:)

IIRC PAGE_OFFSET is the value added to a physical address to obtain
the address in the *kernel's* identity mapping of physical memory.
The macros above look like they're used to convert between the two.
I don't think they have much directly to do with userspace virtual
addresses, whose mappings to physical memory are obtained via the page
tables.

I'm VM-tarded, though, so the above may be a bunch of hooey.

A good place to start with the Linux VM is probably Mel Gorman's VM
documentation, which although focused on 2.4 should give you a good
start.  Which reminds me, I should read this myself.

	http://www.skynet.ie/~mel/projects/vm/
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
