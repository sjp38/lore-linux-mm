Message-ID: <45285FA5.3090205@yahoo.com.au>
Date: Sun, 08 Oct 2006 12:17:09 +1000
From: Nick Piggin <nickpiggin@yahoo.com.au>
MIME-Version: 1.0
Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
References: <20061007105758.14024.70048.sendpatchset@linux.site> <20061007105853.14024.95383.sendpatchset@linux.site> <4527C46F.5050505@garzik.org>
In-Reply-To: <4527C46F.5050505@garzik.org>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Jeff Garzik <jeff@garzik.org>
Cc: Nick Piggin <npiggin@suse.de>, Linux Memory Management <linux-mm@kvack.org>, Andrew Morton <akpm@osdl.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

Jeff Garzik wrote:

> That's pretty nice.
>
> Back when I was writing [the now slated for death] 
> sound/oss/via82xxx_audio.c driver, Linus suggested that I implement 
> ->nopage() for accessing the mmap'able DMA'd audio buffers, rather 
> than using remap_pfn_range().  It worked out very nicely, because it 
> allowed the sound driver to retrieve $N pages for the mmap'able buffer 
> (passed as an s/g list to the hardware) rather than requiring a single 
> humongous buffer returned by pci_alloc_consistent().
>
> And although probably not your primary motivation, your change does 
> IMO improve this area of the kernel.


Thanks. Yeah hopefully this provides a little more flexibility (I think 
it can
already replace 3 individual vm_ops callbacks!). And I'd like to see 
what other
things it can be used for... :)

However, what we don't want is a bloating of struct fault_data IMO. So 
I'd like
to try to nail down the fields that it needs quite quickly then really 
keep a
lid on it.

--

Send instant messages to your online friends http://au.messenger.yahoo.com 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
