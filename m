Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <20061009102635.GC3487@wotan.suse.de>
References: <20061007105758.14024.70048.sendpatchset@linux.site>
	 <20061007105853.14024.95383.sendpatchset@linux.site>
	 <20061007134407.6aa4dd26.akpm@osdl.org>
	 <1160351174.14601.3.camel@localhost.localdomain>
	 <20061009102635.GC3487@wotan.suse.de>
Content-Type: text/plain
Date: Mon, 09 Oct 2006 20:50:14 +1000
Message-Id: <1160391014.10229.16.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> The truncate logic can't be duplicated because it works on struct pages.
> 
> What sounds best, if you use nopfn, is to do your own internal
> synchronisation against your unmap call. Obviously you can't because you
> have no ->nopfn_done call with which to drop locks ;)
> 
> So, hmm yes I have a good idea for how fault() could take over ->nopfn as
> well: just return NULL, set the fault type to VM_FAULT_MINOR, and have
> the ->fault handler install the pte. It will require a new helper along
> the lines of vm_insert_page.
> 
> I'll code that up in my next patchset.

Which is exactly what I was proposing in my other mail :)

Read it, you'll understnad my point about the truncate logic... I
sometimes want to return struct page (when the mapping is pointing to
backup memory) or map it directly to hardware.

In the later case, with an appropriate helper, I can definitely do my
own locking. In the former case, I return struct page's and need the
truncate logic.

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
