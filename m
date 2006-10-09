Subject: Re: [patch 3/3] mm: fault handler to replace nopage and populate
From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
In-Reply-To: <452A50C2.9050409@tungstengraphics.com>
References: <20061009102635.GC3487@wotan.suse.de>
	 <1160391014.10229.16.camel@localhost.localdomain>
	 <20061009110007.GA3592@wotan.suse.de>
	 <1160392214.10229.19.camel@localhost.localdomain>
	 <20061009111906.GA26824@wotan.suse.de>
	 <1160393579.10229.24.camel@localhost.localdomain>
	 <20061009114527.GB26824@wotan.suse.de>
	 <1160394571.10229.27.camel@localhost.localdomain>
	 <20061009115836.GC26824@wotan.suse.de>
	 <1160395671.10229.35.camel@localhost.localdomain>
	 <20061009121417.GA3785@wotan.suse.de>
	 <452A50C2.9050409@tungstengraphics.com>
Content-Type: text/plain
Date: Tue, 10 Oct 2006 06:45:13 +1000
Message-Id: <1160426713.7752.6.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Thomas Hellstrom <thomas@tungstengraphics.com>
Cc: Nick Piggin <npiggin@suse.de>, Andrew Morton <akpm@osdl.org>, Linux Memory Management <linux-mm@kvack.org>, Linux Kernel <linux-kernel@vger.kernel.org>
List-ID: <linux-mm.kvack.org>

> Wouldn't that confuse concurrent readers?
> 
> Could it be an option to make it safe for the fault handler to 
> temporarily drop the mmap_sem read lock given that some conditions TBD 
> are met?
> In that case it can retake the mmap_sem write lock, do the VMA flags 
> modifications, downgrade and do the pte modifications using a helper, or 
> even use remap_pfn_range() during the time the write lock is held?

If we return NOPAGE_REFAULT, then yes, we can drop the mmap sem, though
I 'm not sure we need that...

Ben.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
