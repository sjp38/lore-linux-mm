Subject: Re: [patch 3/8] mm: merge nopfn into fault
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <1179976659.32247.1026.camel@localhost.localdomain>
References: <200705180737.l4I7b6cg010758@shell0.pdx.osdl.net>
	 <alpine.LFD.0.98.0705180817550.3890@woody.linux-foundation.org>
	 <1179963619.32247.991.camel@localhost.localdomain>
	 <20070524014223.GA22998@wotan.suse.de>
	 <alpine.LFD.0.98.0705231857090.3890@woody.linux-foundation.org>
	 <1179976659.32247.1026.camel@localhost.localdomain>
Content-Type: text/plain
Date: Thu, 24 May 2007 13:26:24 +1000
Message-Id: <1179977184.32247.1032.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Cc: Nick Piggin <npiggin@suse.de>, akpm@linux-foundation.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

On Thu, 2007-05-24 at 13:17 +1000, Benjamin Herrenschmidt wrote:
> Fair but in the case of spufs, I -do- have to much with the address in
> the driver/fs since it's the driver that knows it wants to use 64K
> page
> mappings, and thus need to insert the PTE with the special 64K flag in
> the first of the 16 entries of that 64K region -and- align the address
> down before passing it to vm_insert_pfn(). 

Note that I culd just modify the address/page index in the struct
vm_fault... doesn't make much difference in this case.

Might even create an arch helper prepare_special_pgsize_fault() or
something like that that takes the VM fault struct, whack it the right
way, and returns it to the driver for passing to vm_insert_pfn() so that
all of the logic is actually hidden from the driver.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
